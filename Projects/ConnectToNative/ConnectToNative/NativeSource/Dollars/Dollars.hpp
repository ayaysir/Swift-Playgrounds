//
//  Dollars.hpp
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//

#ifndef Dollars_h
#define Dollars_h

#include <iostream>
#include <string> // For std::string

// declare CENTS_PER_DOLLAR
// extern means it can be accessed from multiple compilation units
// constexpr will not work for this - constexpr only works with definitions
extern const int CENTS_PER_DOLLAR;

//
// capture information about (American) dollars and cents
//
class Dollars
{
public:
  Dollars();
  Dollars(int d, int p);
  Dollars(double value);
  
  Dollars& operator+=(Dollars other);
  Dollars& operator-=(Dollars other);
  
  int to_pennies() const;
  int dollars() const;
  int cents() const;
  
  void print(std::ostream&);
  std::string to_string() const;
protected:
  int pennies;
};

inline Dollars operator+(Dollars a, Dollars b) {
  a += b;
  return a;
}

inline Dollars operator-(Dollars a, Dollars b) {
  a -= b;
  return a;
}

#endif
