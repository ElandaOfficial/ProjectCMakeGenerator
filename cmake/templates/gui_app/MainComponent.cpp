${TEMPLATE_LICENSE_NOTICE}

#include "${TEMPLATE_PROJECT_NAME}.h"

//==============================================================================
${TEMPLATE_PROJECT_NAME}::${TEMPLATE_PROJECT_NAME}()
{
    setSize (600, 400);
}

${TEMPLATE_PROJECT_NAME}::~${TEMPLATE_PROJECT_NAME}()
{
}

//==============================================================================
void ${TEMPLATE_PROJECT_NAME}::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setFont (juce::Font (16.0f));
    g.setColour (juce::Colours::white);
    g.drawText ("Hello World!", getLocalBounds(), juce::Justification::centred, true);
}

void ${TEMPLATE_PROJECT_NAME}::resized()
{
    // This is called when the ${TEMPLATE_PROJECT_NAME} is resized.
    // If you add any child components, this is where you should
    // update their positions.
}
