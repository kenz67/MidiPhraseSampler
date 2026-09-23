#ifndef LOOPER_STATES_H
#define LOOPER_STATES_H

enum class LooperStates {
    Empty,
    Recording,
    Playing,
    Paused,
};

static const char* const stateNames[] = {
  "IDLE",
  "RECORDING",
  "PLAYING",
  "PAUSED"
};

#endif