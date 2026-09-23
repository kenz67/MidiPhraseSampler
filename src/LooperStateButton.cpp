#include "LooperStateButton.h"
#include "Debug.h"

LooperStateButton::LooperStateButton(
    byte pin, byte channel, byte ccNumber1, byte value1,
    byte ccNumber2, byte value2, byte longPressccNumber,
    byte longPressValue, unsigned long longPressDurationMs)
    : ButtonControl(pin, channel, ccNumber1, value1, longPressccNumber,
                    longPressValue, longPressDurationMs),
      _channel(channel),
      _ccNumber1(ccNumber1),
      _value1(value1),
      _ccNumber2(ccNumber2),
      _value2(value2),
      _longPressccNumber(longPressccNumber),
    _longPressValue(longPressValue) {}

void LooperStateButton::onButtonPress() {
    switch (_state) {
    case LooperStates::Empty:
        sendControlMessage(_ccNumber1, _value1);
        _state = LooperStates::Recording;
        break;
    case LooperStates::Recording:
        sendControlMessage(_ccNumber2, _value2);
        _state = LooperStates::Playing;
        break;
    case LooperStates::Playing:
        sendControlMessage(_ccNumber2, _value2);
        _state = LooperStates::Paused;
        break;
    case LooperStates::Paused:
        sendControlMessage(_ccNumber2, _value2);
        _state = LooperStates::Playing;
        break;
    }

    Debug::printNameValuePair("\033[32mState set to\033[0m", stateNames[static_cast<int>(_state)]);
}

void LooperStateButton::onLongPress() {
    midiEventPacket_t message = {
        0x0B, uint8_t(0xB0 | _channel), _longPressccNumber, _longPressValue};
    sendMidiMsg(message);
    _state = LooperStates::Empty;
    Debug::printNameValuePair("\033[32mState set to\033[0m", stateNames[static_cast<int>(_state)]);
}

void LooperStateButton::sendControlMessage(byte ccNumber, byte value) {
    midiEventPacket_t message = {0x0B, uint8_t(0xB0 | _channel), ccNumber, value};
    sendMidiMsg(message);
}