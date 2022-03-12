${TEMPLATE_LICENSE_NOTICE}

#pragma once

#include <juce_gui_basics/juce_gui_basics.h>

//==============================================================================
/*
    This component lives inside our window, and this is where you should put all
    your controls and content.
*/
class ${TEMPLATE_PROJECT_NAME} : public juce::Component
{
public:
    //==============================================================================
    ${TEMPLATE_PROJECT_NAME}();
    ~${TEMPLATE_PROJECT_NAME}() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    //==============================================================================
    // Your private member variables go here...


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (${TEMPLATE_PROJECT_NAME})
};
