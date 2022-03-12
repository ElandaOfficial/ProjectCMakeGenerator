########################################################################################################################
function(project_generate_template)
    set(template_dir "${CMAKE_CURRENT_LIST_DIR}/cmake/templates")
    set(source_dir   "${CMAKE_CURRENT_LIST_DIR}/src")
    
    ### Template vars
    string(TIMESTAMP TEMPLATE_TIMESTAMP "%d, %B %Y")
    
    set(TEMPLATE_CLASS_NAME   ${JUCE_PROJECT_MAIN_CLASS})
    set(TEMPLATE_PROJECT_NAME ${JUCE_PROJECT_NAME})
    
    if (NOT "${JUCE_PROJECT_LICENSE_NOTICE}" STREQUAL "")
        set(TEMPLATE_LICENSE_NOTICE_START
            "/*\n"
            "    ======================================================\n"
            "    ${JUCE_PROJECT_LICENSE_NOTICE}\n"
            "    ======================================================\n\n")
    else()
        set(TEMPLATE_LICENSE_NOTICE_START
            "/*\n"
            "    ======================================================\n\n")
    endif()
    
    file(READ "${template_dir}/${JUCE_PROJECT_TYPE}/template.json" json_template_data)
    
    string(JSON out_file_list
        GET "${json_template_data}" files)
    string(JSON out_file_list_length
        LENGTH "${json_template_data}" files)
    
    if ("${out_file_list_length}" GREATER 0)
        math(EXPR out_last_index "${out_file_list_length}-1")
        
        foreach(i RANGE ${out_last_index})
            string(JSON out_file_obj
                GET "${out_file_list}" ${i})
            
            string(JSON out_file_name
                GET "${out_file_obj}" name)
            string(JSON out_file_action
                GET "${out_file_obj}" action)
            string(JSON out_file_alt
                ERROR_VARIABLE out_alt_error
                GET "${out_file_obj}" alt)
            
            set(new_file_name "${out_file_name}")
            
            if (NOT out_alt_error AND NOT "${out_file_alt}" STREQUAL "")
                string(CONFIGURE "${out_file_alt}" new_file_name)
            endif()
            
            if (NOT EXISTS "${source_dir}/${new_file_name}")
                message("Processing template '${out_file_name}'...")
    
                if ("${out_file_action}" STREQUAL "configure")
                    set(TEMPLATE_LICENSE_NOTICE
                        "${TEMPLATE_LICENSE_NOTICE_START}"
                        "    @author ${JUCE_PROJECT_AUTHOR}\n"
                        "    @file   ${new_file_name}\n"
                        "    @date   ${TEMPLATE_TIMESTAMP}\n\n"
                        "    ======================================================\n"
                        "*/")
                    list(JOIN TEMPLATE_LICENSE_NOTICE "" TEMPLATE_LICENSE_NOTICE)
                    
                    file(READ "${template_dir}/${JUCE_PROJECT_TYPE}/${out_file_name}" out_file_source)
                    file(CONFIGURE OUTPUT "${source_dir}/${new_file_name}"
                        CONTENT "${out_file_source}")
                    message("Done configuring (${new_file_name})")
                elseif("${out_file_action}" STREQUAL "copy")
                    file(COPY_FILE "${template_dir}/${JUCE_PROJECT_TYPE}/${out_file_name}" "${source_dir}/${new_file_name}")
                    message("Done copying (${new_file_name})")
                else()
                    file(REMOVE "${source_dir}/${out_file_name}")
                    message(FATAL_ERROR "Invalid file processing action '${out_file_action}'")
                endif()

                message("")
            else()
                message("Skipping ${new_file_name}")
            endif()
        endforeach()
    endif()
    
    set(TEMPLATE_LICENSE_NOTICE
        "${TEMPLATE_LICENSE_NOTICE_START}"
        "    @author ${JUCE_PROJECT_AUTHOR}\n"
        "    @file   ${new_file_name}\n"
        "    @date   ${TEMPLATE_TIMESTAMP}\n\n"
        "    ======================================================\n"
        "*/")
    list(JOIN TEMPLATE_LICENSE_NOTICE "" TEMPLATE_LICENSE_NOTICE)

    file(READ "${template_dir}/ProjectDetails.h" out_file_source)
    file(CONFIGURE OUTPUT "${source_dir}/ProjectDetails.h"
        CONTENT "${out_file_source}")
endfunction()
