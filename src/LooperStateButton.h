#ifndef LOOPER_STATE_BUTTON_H
#define LOOPER_STATE_BUTTON_H

#include <ButtonControl.h>
#include "LooperStates.h"

class LooperStateButton : public ButtonControl {
public:
    LooperStateButton(byte pin, byte channel, byte ccNumber1, byte value1,
                      byte ccNumber2 = 0, byte value2 = 0,
                      byte longPressccNumber = 0, byte longPressValue = 0,
                      unsigned long longPressDurationMs = 0
                      );

protected:
    void onButtonPress() override;
    void onLongPress() override;

private:
    void sendControlMessage(byte ccNumber, byte value);
    void sendLongPressMessage();
    void handleButtonPress();

    LooperStates _state = LooperStates::Empty;
    byte _channel;
    byte _ccNumber1;
    byte _value1;
    byte _ccNumber2;
    byte _value2;
    byte _longPressccNumber;
    byte _longPressValue;
};

#endif
