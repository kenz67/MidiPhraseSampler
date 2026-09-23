#include <MidiController.h>
#include "src/LooperStateButton.h"

ButtonBase* buttons[] = {
    //new ButtonNote(13, 0, midiNote[Gb][4]),
    new LooperStateButton(
        13,    //pin
        0,     //channel
        14, 0, //ccNumber1, value1  (Record)
        15, 0, //ccNumber2, value2  (Play/Pause)
        16, 0, //longPressccNumber, longPressValue  (Clear)
        1000   //longPressDurationMs
    ),
    new ButtonLatch(4, 1, 29),
};

PotentiometerBase* pots[] = {};

// PotentiometerBase* pots[] = {
//     new Potentiometer(A0, 1, 31, 0),
//};

const short NUM_BUTTONS = sizeof(buttons) / sizeof(buttons[0]);
const short NUM_POTS = sizeof(pots) / sizeof(pots[0]);

void setup() {
    MidiController::setup(buttons, NUM_BUTTONS, pots, NUM_POTS);
}

void loop() {
    MidiController::update(buttons, NUM_BUTTONS, pots, NUM_POTS);
    delay(1);
    yield();
}
