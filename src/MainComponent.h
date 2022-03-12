/*
    ======================================================

    @author Elanda
    @file   MainComponent.h
    @date   25, November 2021

    ======================================================
*/

#pragma once

#include <juce_gui_basics/juce_gui_basics.h>

//==============================================================================
/*
    This component lives inside our window, and this is where you should put all
    your controls and content.
*/
class TestProject : public juce::Component
{
public:
    //==============================================================================
    TestProject();
    ~TestProject() override;

    //==============================================================================
    void paint (juce::Graphics&) override;
    void resized() override;

private:
    //==============================================================================
    // Your private member variables go here...


    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TestProject)
};
