/*
    ======================================================

    @author Elanda
    @file   MainComponentWhatever.cpp
    @date   25, November 2021

    ======================================================
*/

#include "TestProject.h"

//==============================================================================
TestProject::TestProject()
{
    setSize (600, 400);
}

TestProject::~TestProject()
{
}

//==============================================================================
void TestProject::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setFont (juce::Font (16.0f));
    g.setColour (juce::Colours::white);
    g.drawText ("Hello World!", getLocalBounds(), juce::Justification::centred, true);
}

void TestProject::resized()
{
    // This is called when the TestProject is resized.
    // If you add any child components, this is where you should
    // update their positions.
}
