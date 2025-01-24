//
//  DollarsWrapper.mm
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//

#import "DollarsWrapper.h"
#include "Dollars.hpp" // C++ Dollars 클래스 포함

@implementation DollarsWrapper {
  Dollars *dollars; // 내부적으로 C++ 객체를 보관
}

- (instancetype)initWithDollars:(int)d cents:(int)c {
  self = [super init];
  if (self) {
    dollars = new Dollars(d, c); // C++ 객체 생성
  }
  return self;
}

- (instancetype)initWithDouble:(double)value {
  self = [super init];
  if (self) {
    dollars = new Dollars(value);
  }
  return self;
}

- (void)addDollars:(DollarsWrapper *)other {
  *dollars += *other->dollars; // C++ 연산자 호출
}

- (void)subtractDollars:(DollarsWrapper *)other {
  *dollars -= *other->dollars; // C++ 연산자 호출
}

- (NSString *)toString {
  std::string result = dollars->to_string(); // C++ to_string 호출
  return [NSString stringWithUTF8String:result.c_str()]; // NSString 변환
}

- (int)toPennies {
  return dollars->to_pennies();
}

- (int)dollars {
  return dollars->dollars();
}

- (int)cents {
  return dollars->cents();
}

- (void)dealloc {
  delete dollars; // C++ 객체 삭제
}

@end
