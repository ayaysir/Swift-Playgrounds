//
//  LeapYear.h
//  ConnectToNative
//
//  Created by 윤범태 on 1/24/25.
//

#ifndef LeapYear_h
#define LeapYear_h

// include 작성
#include <stdbool.h>

// 함수 목록을 적어
bool isLeapYear(int year);

#endif

/*
 다음 할 일:
 ConnectToNative-Bridging-Header에 추가
 
 #import "LeapYear.h"
 
 헤더 경로 설정:
 1.  Xcode에서 브리징 헤더 설정 경로 확인:
 •  Target > Build Settings로 이동.
 •  Objective-C Bridging Header를 검색.
 •  경로가 정확히 지정되어 있는지 확인합니다:
 */
