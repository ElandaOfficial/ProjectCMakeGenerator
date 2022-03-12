cmake_minimum_required(VERSION 3.19)

include(cmake/ProjectReader.cmake)
include(cmake/TemplateGenerator.cmake)
include(cmake/cpm/cmake/CPM.cmake)

read_project_json("${CMAKE_CURRENT_LIST_DIR}/project.json")

foreach(i RANGE ${PROJECT_SETTINGS_LAST_INDX})
    list(GET JUCE_PROJECT_SETTINGS_LIST_VALS ${i} jupro_setting_value)
    list(GET JUCE_PROJECT_SETTINGS_LIST_NAME ${i} jupro_setting_name)
    list(GET JUCE_PROJECT_SETTINGS_LIST_TYPE ${i} jupro_setting_type)
    list(GET JUCE_PROJECT_SETTINGS_LIST_CACH ${i} jupro_setting_is_cached)
    list(GET JUCE_PROJECT_SETTINGS_LIST_DESC ${i} jupro_setting_text)
    
    if (jupro_setting_is_cached)
        set(${jupro_setting_name} ${jupro_setting_value} CACHE ${jupro_setting_type} ${jupro_setting_text})
    else()
        set(${jupro_setting_name} ${jupro_setting_value})
    endif()
endforeach()

project_unset_retired_variables()

project(${JUCE_PROJECT_ID}
    VERSION      ${JUCE_PROJECT_VERSION}
    DESCRIPTION  "${JUCE_PROJECT_SUMMARY}"
    HOMEPAGE_URL "${JUCE_PROJECT_SITE}"
    LANGUAGES    C CXX)

message("Generating sources for project '${JUCE_PROJECT_NAME}' (${JUCE_PROJECT_TYPE}):")
project_generate_template()

set(JUCE_PACKAGE_STRING "juce-framework/JUCE")

if (NOT "${JUCE_PROJECT_GIT_VERSION}" STREQUAL "")
    set(JUCE_PACKAGE_STRING "juce-framework/JUCE#${JUCE_PROJECT_GIT_VERSION}")
endif()

if (NOT "${JUCE_PROJECT_GIT_BRANCH}" STREQUAL "")
    set(JUCE_PACKAGE_STRING "juce-framework/JUCE#${JUCE_PROJECT_GIT_BRANCH}")
endif()

CPMAddPackage("gh:${JUCE_PACKAGE_STRING}")

add_subdirectory(lib)
add_subdirectory(src)
add_subdirectory(res)

cmake_language(CALL juce_add_${JUCE_PROJECT_TYPE}
    VERSION      "${JUCE_PROJECT_VERSION}"
    PRODUCT_NAME "${JUCE_PROJECT_NAME}"
    )
