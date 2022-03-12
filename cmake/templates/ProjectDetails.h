${TEMPLATE_LICENSE_NOTICE}

#pragma once

struct ProjectDetails
{
    /** The global name of the project. */
    static constexpr const char *name = "${JUCE_PROJECT_NAME}";

    /** The global version string of the project. */
    static constexpr const char *version = "${JUCE_PROJECT_VERSION}";
};

