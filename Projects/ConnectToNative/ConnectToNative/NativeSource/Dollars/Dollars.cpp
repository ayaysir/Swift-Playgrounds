//
//  Dollars.cpp
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//  https://faculty-web.msoe.edu/hasker/resources/cpp/account/
//

#include "Dollars.hpp"
#include <cmath>
#include <iostream>
#include <string> // For std::string
using namespace std;

/// 1달러에 100센트가 있다는 것을 나타내는 상수입니다.
const int CENTS_PER_DOLLAR = 100;

/// pennies 멤버 변수를 0으로 초기화합니다. 이는 객체 생성 시 기본값으로 0달러를 의미합니다.
Dollars::Dollars() : pennies(0) { }

/// 달러(d)와 센트(p) 값을 받아 이를 총 센트(pennies)로 변환합니다.
Dollars::Dollars(int d, int p)
   : pennies(d * CENTS_PER_DOLLAR + p)
{ }

/// 소수 값으로 초기화
/// - 소수값(예: 12.34)을 받아 pennies로 변환합니다.
/// - 반올림을 통해 정확도를 유지합니다.
Dollars::Dollars(double value)
{
   if ( value >= 0.0 )
      pennies = int(value * CENTS_PER_DOLLAR + 0.5);
   else
      pennies = int(value * CENTS_PER_DOLLAR - 0.5);
}

/// += 오버로딩
/// - 다른 Dollars 객체의 값을 현재 객체에 더하고, 자기 자신을 반환합니다.
Dollars& Dollars::operator+=(Dollars other) {
   pennies += other.pennies;
   return *this;
}

/// -= 오버로딩
/// - 다른 Dollars 객체의 값을 현재 객체에서 빼고, 자기 자신을 반환합니다.
Dollars& Dollars::operator-=(Dollars other) {
   pennies -= other.pennies;
   return *this;
}

/// 객체의 값을 센트 단위로 반환합니다.
int Dollars::to_pennies() const
{
   return pennies;
}

/// 전체 달러 값을 반환합니다.
int Dollars::dollars() const
{
   return pennies / CENTS_PER_DOLLAR;
}

/// 센트 부분만 반환합니다.
int Dollars::cents() const
{
   return pennies % CENTS_PER_DOLLAR;
}

/// - ostream 객체를 사용하여 값을 달러.센트 형식으로 출력합니다.
/// - 센트가 한 자리 숫자인 경우 앞에 0을 붙입니다.
void Dollars::print(ostream& out)
{
   out << dollars() << ".";
   if ( abs(cents()) < 10 )
      out << '0';
   out << abs(cents());
}

/// - std::string 타입을 사용하여 값을 달러.센트 형식으로 반환합니다.
/// - 센트가 한 자리 숫자인 경우 앞에 0을 붙입니다.
string Dollars::to_string() const
{
  string result = std::to_string(dollars()) + ".";
  if (abs(cents()) < 10) {
    result += "0";
  }
  result += std::to_string(abs(cents()));
  return result;
}
