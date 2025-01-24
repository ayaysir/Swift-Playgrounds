//
//  DollarsWrapper.h
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//

#import <Foundation/Foundation.h>

@interface DollarsWrapper : NSObject

- (instancetype)initWithDollars:(int)d cents:(int)c;
- (instancetype)initWithDouble:(double)value;

- (void)addDollars:(DollarsWrapper *)other;
- (void)subtractDollars:(DollarsWrapper *)other;

- (NSString *)toString;

// 전체 값을 센트 단위로 반환
- (int)toPennies;

// 달러 부분만 반환
- (int)dollars;

// 센트 부분만 반환
- (int)cents;

@end

/*
 C++로 작성된 Dollars 클래스를 Swift에서 사용하려면 Objective-C++ 브리지 계층을 사용해야 합니다. Swift는 직접적으로 C++ 클래스를 다룰 수 없기 때문에 Objective-C++로 작성된 래퍼 클래스를 통해 C++ 코드를 호출하는 방식으로 구현합니다.

 Objective-C++ 브리지 클래스 생성

 Objective-C++(.mm) 파일을 생성하여 Swift에서 Dollars 클래스를 사용할 수 있도록 래핑합니다.

 파일 구성
   •  Dollars.hpp: 기존 C++ 클래스 헤더 정의.
   •  Dollars.cpp: 기존 C++로 작성된 부분.
   •  DollarsWrapper.h: Objective-C 래퍼 클래스 정의.
   •  DollarsWrapper.mm: Objective-C++ 래퍼 클래스 구현.
 */
