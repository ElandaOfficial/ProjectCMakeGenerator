########################################################################################################################
set(JUCE_PROJECT_CONST_VERSION_FORMAT  "[0-9]+.[0-9]+(.[0-9]+)?")
set(JUCE_PROJECT_CONST_VALID_APP_TYPES gui_app console_app plugin)

########################################################################################################################
function(verify_type type value)
    if ("${type}" STREQUAL "numeric")
        if (NOT "${value}" MATCHES "[0-9]+")
            set(check_failed TRUE PARENT_SCOPE)
        endif()
    elseif ("${type}" STREQUAL "bool")
        string(TOLOWER "${value}" lc_check)

        if (NOT "${lc_check}" STREQUAL "true" AND NOT "${lc_check}" STREQUAL "false"
            AND NOT "${lc_check}" STREQUAL "on" AND NOT "${lc_check}" STREQUAL "off")
            set(check_failed TRUE PARENT_SCOPE)
        endif()
    elseif ("${type}" STREQUAL "version")
        if (NOT "${value}" MATCHES "[0-9]+.[0-9]+(.[0-9]+)?")
            set(check_failed TRUE PARENT_SCOPE)
        endif()
    elseif ("${type}" STREQUAL "array")
        
    elseif ("${type}" STREQUAL "string")
    else()
        message(AUTHOR_WARNING "Invalid type ${type}")
    endif()
endfunction()

########################################################################################################################
function(project_ensure_type json member type)
    string(JSON out_type
        ERROR_VARIABLE out_error
        TYPE "${json}" "${member}")

    if (out_error)
        return()
    endif()
    
    if (NOT "${out_type}" STREQUAL "${type}")
        message(FATAL_ERROR "Project ${member} must be a ${type}")
    endif()
endfunction()

function(project_get_value_required json member out)
    string(JSON out_value
        ERROR_VARIABLE out_error
        GET "${json}" ${member})
    
    if (out_error)
        message(FATAL_ERROR "'${member}' is a required project field")
    endif()
        
    set(${out} "${out_value}" PARENT_SCOPE)
endfunction()

function(project_get_value_optional json member out)
    string(JSON out_value
        ERROR_VARIABLE out_error
        GET "${json}" ${member})
    
    if (out_error)
        set(${out} NOTFOUND PARENT_SCOPE)
        return()
    endif()
    
    set(${out} "${out_value}" PARENT_SCOPE)
endfunction()

macro(require_and_set json name member type)
    project_ensure_type("${json}" "${member}" "${type}")
    project_get_value_required("${json}" "${member}" project_${name})
    set(JUCE_PROJECT_${name} "${project_${name}}")
    set(JUCE_PROJECT_${name} "${project_${name}}" PARENT_SCOPE)
endmacro()

macro(optional_and_set json name member type)
    project_ensure_type("${json}" "${member}" "${type}")
    project_get_value_optional("${json}" "${member}" project_${name})
    
    if (NOT "${project_${name}}" STREQUAL "NOTFOUND")
        set(JUCE_PROJECT_${name} "${project_${name}}")
        set(JUCE_PROJECT_${name} "${project_${name}}" PARENT_SCOPE)
    endif()
endmacro()

########################################################################################################################
function(process_setting_value type name value)
    if ("${type}" STREQUAL "OBJECT")
        message(FATAL_ERROR "Invalid value '${value}' for setting '${name}'")
    endif()
    
    if ("${type}" STREQUAL "ARRAY")
        string(JSON out_array_num
            LENGTH "${json}")
        set(array_type NONE)
        
        math(EXPR out_array_length "${out_array_num}-1")

        foreach(i RANGE ${out_length})
            string(JSON out_array_value
                GET "${out_value}" ${i})
            
            if ("${array_type}" STREQUAL "NONE")
                string(JSON out_array_type
                    TYPE "${out_value}" ${i})
                set(array_type "${out_array_type}")
            endif()
            
            list(APPEND array_values "${out_array_value}")
        endforeach()
        
        list(JOIN array_values " " out_list_values)
        
        set(VALUE_RESULT "${out_list_values}" PARENT_SCOPE)
        set(VALUE_TYPE   "${array_type}"      PARENT_SCOPE)
    else()
        set(VALUE_RESULT "${value}" PARENT_SCOPE)
        set(VALUE_TYPE   "${type}"  PARENT_SCOPE)
    endif()
endfunction()

function(project_get_settings json)
    string(JSON out_length
        LENGTH "${json}")
    
    if ("${out_length}" GREATER 0)
        math(EXPR out_last_index "${out_length}-1")

        foreach(i RANGE ${out_last_index})
            string(JSON out_name
                MEMBER "${json}" ${i})
            string(JSON out_type
                TYPE "${json}" ${out_name})
            string(JSON out_value
                GET "${json}" ${out_name})
    
            set(is_cached         FALSE)
            set(cache_description "")
            
            if ("${out_type}" STREQUAL "OBJECT")
                string(JSON out_obj_value
                    GET "${out_value}" value)
                string(JSON out_obj_value_type
                    TYPE "${out_value}" value)
                
                string(JSON out_obj_cached
                    ERROR_VARIABLE out_error
                    MEMBER         "${out_value}" cached)
                
                if (NOT out_error)
                    string(JSON out_obj_cached_type
                        TYPE "${out_value}" cached)
                    
                    if (NOT "${out_obj_cached_type}" STREQUAL "BOOLEAN")
                        message(FATAL_ERROR "Cached option for '${out_name}' must be either true or false")
                    endif()
                    
                    set(is_cached ${out_obj_cached})
    
                    string(JSON out_obj_cached_text
                        ERROR_VARIABLE out_error
                        MEMBER         "${out_value}" text)
                    
                    if (NOT out_error)
                        string(JSON out_obj_cached_text_type
                            TYPE "${out_value}" text)
    
                        if (NOT "${out_obj_cached_type}" STREQUAL "STRING")
                            message(FATAL_ERROR "Cache description for '${out_name}' must be a string")
                        endif()
                        
                        set(cache_description "${out_obj_cached_text}")
                    endif()
                endif()
                
                process_setting_value("${out_obj_value_type}" "${out_name}" "${out_obj_value}")
            else()
                process_setting_value("${out_type}" "${out_name}" "${out_value}")
            endif()
            
            if ("${VALUE_TYPE}" STREQUAL "BOOLEAN")
                set(VALUE_TYPE BOOL)
            elseif("${VALUE_TYPE}" STREQUAL "NUMBER" OR "${VALUE_TYPE}" STREQUAL "NULL")
                set(VALUE_TYPE STRING)
            endif()
            
            list(APPEND PROJECT_SETTINGS_LIST_VALS ${VALUE_RESULT})
            list(APPEND PROJECT_SETTINGS_LIST_NAME ${out_name})
            list(APPEND PROJECT_SETTINGS_LIST_TYPE ${VALUE_TYPE})
            list(APPEND PROJECT_SETTINGS_LIST_CACH ${is_cached})
            list(APPEND PROJECT_SETTINGS_LIST_DESC ${cache_description})
        endforeach()

        set(PROJECT_SETTINGS_LIST_VALS ${PROJECT_SETTINGS_LIST_VALS} PARENT_SCOPE)
        set(PROJECT_SETTINGS_LIST_NAME ${PROJECT_SETTINGS_LIST_NAME} PARENT_SCOPE)
        set(PROJECT_SETTINGS_LIST_TYPE ${PROJECT_SETTINGS_LIST_TYPE} PARENT_SCOPE)
        set(PROJECT_SETTINGS_LIST_CACH ${PROJECT_SETTINGS_LIST_CACH} PARENT_SCOPE)
        set(PROJECT_SETTINGS_LIST_DESC ${PROJECT_SETTINGS_LIST_DESC} PARENT_SCOPE)
        set(PROJECT_SETTINGS_LAST_INDX "${out_last_index}"           PARENT_SCOPE)
    endif()
endfunction()

########################################################################################################################
macro(project_get_juce_settings json)
    ### JUCE DEPENDENCY
    project_ensure_type("${json}" "git" "OBJECT")
    project_get_value_optional("${json}" "git" json_git)
    
    set(JUCE_PROJECT_MAIN_CLASS "MainComponent" PARENT_SCOPE)
    
    if (NOT "${json_git}" STREQUAL "NOTFOUND")
        project_ensure_type("${json_git}" "branch" "STRING")
        project_get_value_optional("${json_git}" "branch" out_git_branch)

        project_ensure_type("${json_git}" "version" "STRING")
        project_get_value_optional("${json_git}" "version" out_git_version)
        
        if (NOT "${out_git_branch}" STREQUAL "")
            if ("${out_git_branch}" MATCHES "[0-9]+.[0-9]+.[0-9]")
                message(FATAL_ERROR "Invalid JUCE package branch '${out_git_branch}', \
                                     for version numbers use 'version'")
            endif()

            set(JUCE_PROJECT_GIT_BRANCH "${out_git_branch}" PARENT_SCOPE)
        endif()
    
        if (NOT "${out_git_version}" STREQUAL "")
            if (NOT "${out_git_version}" MATCHES "[0-9]+.[0-9]+.[0-9]")
                message(FATAL_ERROR "Invalid JUCE package version '${out_git_version}', \
                                     for branch names, commit-hashes and tag name use 'branch'")
            endif()

            set(JUCE_PROJECT_GIT_VERSION "${out_git_version}" PARENT_SCOPE)
        endif()
        
        if (NOT "${out_git_branch}" STREQUAL "" AND NOT "${out_git_version}" STREQUAL "")
            message(WARNING "JUCE package 'version' and 'branch' are both set, \
                             'branch' has higher precedence and will therefore override 'version'")
        endif()
    endif()

    ### JUCE MODULES
    project_ensure_type("${json}" "modules" "ARRAY")
    project_get_value_optional("${json}" "modules" json_modules)

    if (NOT "${json_modules}" STREQUAL "NOTFOUND")
        string(JSON out_length
            LENGTH "${json_modules}")
        
        if ("${out_length}" GREATER 0)
            math(EXPR out_last_index "${out_length}-1")

            foreach(i RANGE ${out_last_index})
                string(JSON out_module_type
                    TYPE "${json_modules}" ${i})
                string(JSON out_module_value
                    GET "${json_modules}" ${i})

                if (NOT "${out_module_type}" STREQUAL "STRING")
                    message(FATAL_ERROR "Invalid module name '${out_module_value}', \
                                     must be a string but found '${out_module_type}'")
                endif()

                list(APPEND juce_module_defs "${out_module_value}")
            endforeach()
        endif()
        
        set(JUCE_PROJECT_LINKED_MODULES "${juce_module_defs}" PARENT_SCOPE)
    endif()
    
    ### JUCE PROJECT
    project_ensure_type("${json}" "project" "OBJECT")
    project_get_value_required("${json}" "project" json_project)

    project_ensure_type("${json_project}" "type" "STRING")
    project_get_value_required("${json_project}" "type" project_type)
    
    if (NOT "${project_type}" IN_LIST JUCE_PROJECT_CONST_VALID_APP_TYPES)
        message(FATAL_ERROR "Invalid project type '${project_type}', \
                             valid are: gui_app, console_app and plugin")
    endif()
    
    set(JUCE_PROJECT_TYPE "${project_type}" PARENT_SCOPE)
    
    project_ensure_type("${json_project}" "class" "STRING")
    project_get_value_optional("${json_project}" "class" project_main_class)
    
    if (NOT "${project_main_class}" STREQUAL "NOTFOUND" AND NOT "${project_main_class}" STREQUAL "")
        set(JUCE_PROJECT_MAIN_CLASS "${project_main_class}" PARENT_SCOPE)
    endif()
    
endmacro()

########################################################################################################################
function(read_project_json path)
    file(READ "${path}" json)
    
    # project settings
    require_and_set("${json}" "NAME"    "name"    "STRING")
    require_and_set("${json}" "ID"      "id"      "STRING")
    require_and_set("${json}" "VERSION" "version" "STRING")
    
    optional_and_set("${json}" "SUMMARY" "description" "STRING")
    optional_and_set("${json}" "WEBSITE" "website"     "STRING")
    optional_and_set("${json}" "AUTHOR"  "author"      "STRING")

    if (NOT "${JUCE_PROJECT_NAME}" MATCHES "[a-zA-Z_][a-zA-Z0-9_]+")
        message(FATAL_ERROR "Invalid project name '${JUCE_PROJECT_NAME}', \
                             a name can only contain upper/lower-case letters, \
                             underscores and numbers which are not in the beginning")
    endif()

    if (NOT "${JUCE_PROJECT_NAME}" MATCHES "[a-zA-Z_][a-zA-Z0-9_]+")
        message(FATAL_ERROR "Invalid project id '${JUCE_PROJECT_ID}', \
                             an id can only contain upper/lower-case letters, \
                             underscores and numbers which are not in the beginning")
    endif()
    
    if (NOT "${JUCE_PROJECT_VERSION}" MATCHES ${JUCE_PROJECT_CONST_VERSION_FORMAT})
        message(FATAL_ERROR "Project version '${JUCE_PROJECT_VERSION}' is not a valid version number (e.g 1.0 or 1.0.0)")
    endif()
    
    # cmake variables
    project_ensure_type("${json}" "settings" "OBJECT")
    project_get_value_optional("${json}" "settings" json_settings)
    project_get_settings("${json_settings}")
    
    set(JUCE_PROJECT_SETTINGS_LIST_VALS ${PROJECT_SETTINGS_LIST_VALS} PARENT_SCOPE)
    set(JUCE_PROJECT_SETTINGS_LIST_NAME ${PROJECT_SETTINGS_LIST_NAME} PARENT_SCOPE)
    set(JUCE_PROJECT_SETTINGS_LIST_TYPE ${PROJECT_SETTINGS_LIST_TYPE} PARENT_SCOPE)
    set(JUCE_PROJECT_SETTINGS_LIST_CACH ${PROJECT_SETTINGS_LIST_CACH} PARENT_SCOPE)
    set(JUCE_PROJECT_SETTINGS_LIST_DESC ${PROJECT_SETTINGS_LIST_DESC} PARENT_SCOPE)
    set(JUCE_PROJECT_SETTINGS_LAST_INDX "${out_length}"               PARENT_SCOPE)
    
    # juce settings
    project_ensure_type("${json}" "juce" "OBJECT")
    project_get_value_required("${json}" "juce" json_juce)
    project_get_juce_settings("${json_juce}")
endfunction()

macro(project_unset_retired_variables)
    unset(JUCE_PROJECT_SETTINGS_LIST_VALS)
    unset(JUCE_PROJECT_SETTINGS_LIST_NAME)
    unset(JUCE_PROJECT_SETTINGS_LIST_TYPE)
    unset(JUCE_PROJECT_SETTINGS_LIST_CACH)
    unset(JUCE_PROJECT_SETTINGS_LIST_DESC)
    unset(JUCE_PROJECT_SETTINGS_LAST_INDX)
endmacro()
