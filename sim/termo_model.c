#include "math.h"

#define COEF 0.00001
#define LOW_VALUE -45   
#define SIGNAL_COEF 0.0001

int get_temp(int signal) {
  static float valueSpeed, signalSpeed, value = 30;
  static float valueSpeed_f, signalSpeed_f;
  if (abs(signalSpeed - signal) > 1) {
      if (signalSpeed < signal) signalSpeed += 0.6;
      if (signalSpeed > signal) signalSpeed -= 0.3;
  } else {
      signalSpeed = signal;
  }
  signalSpeed_f += (signalSpeed - signalSpeed_f) * 0.1;
  valueSpeed = signalSpeed_f * SIGNAL_COEF + (LOW_VALUE - value) * COEF;
  value += valueSpeed;
  return value;
}