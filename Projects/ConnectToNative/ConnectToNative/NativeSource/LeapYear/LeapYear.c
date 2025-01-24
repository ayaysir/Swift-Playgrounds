//
//  LeapYear.c
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//

#include "LeapYear.h"
#include <stdbool.h> // for true/false

// 윤년 여부를 판단하는 함수
bool isLeapYear(int year) {
  // leap year if perfectly divisible by 400
  if (year % 400 == 0) {
    return true;
  }
  // not a leap year if divisible by 100
  // but not divisible by 400
  else if (year % 100 == 0) {
    return false;
  }
  // leap year if not divisible by 100
  // but divisible by 4
  else if (year % 4 == 0) {
    return true;
  }
  // all other years are not leap years
  else {
    return false;
  }
}
