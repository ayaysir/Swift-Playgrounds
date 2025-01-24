## iOS 프로젝트에 C 파일 불러오기

iOS 프로젝트에서 C 언어를 사용하여 앱을 만들려면, Swift나 Objective-C와 같은 언어와 함께 C 코드를 활용하는 방식으로 진행해야 합니다. iOS 프로젝트는 기본적으로 UIKit 또는 SwiftUI를 기반으로 동작하므로, UI 구성은 Swift/Objective-C로 작성하고 C 언어는 주로 비즈니스 로직이나 특정 기능 구현에 사용됩니다.  

아래는 iOS 프로젝트에서 C 언어 코드를 포함하는 간단한 예제입니다.  

---

### 1. **Xcode에서 프로젝트 생성**
1. Xcode를 실행하고 새로운 "iOS App" 프로젝트를 생성합니다.  
2. Interface는 **SwiftUI** 또는 **UIKit** 중 하나를 선택합니다.  
3. Language는 **Swift**를 선택합니다.

---

### 2. **C 파일 추가**
1. Xcode 프로젝트 내에서 **File > New > File...** 을 클릭합니다.  
2. **C File**을 선택하고 이름을 지정한 후 생성합니다(예: `MyCCode.c`).  
3. C 파일을 추가하면, Xcode는 "Objective-C Bridging Header" 파일 생성을 묻습니다. **"Yes"**를 선택합니다.  
   - 이 헤더 파일은 Swift와 C 코드 간의 브릿지를 제공합니다.

---

### 3. **C 파일 작성**  
`MyCCode.c` 파일에 간단한 C 함수를 작성합니다:  

```c
#include "MyCCode.h"

int addTwoNumbers(int a, int b) {
  return a + b;
}
```

---

### 4. **헤더 파일 추가**  
`MyCCode.h` 파일을 작성하여 C 함수의 선언부를 추가합니다:  

```c
#ifndef MyCCode_h
#define MyCCode_h

int addTwoNumbers(int a, int b);

#endif /* MyCCode_h */
```

---

### 5. **Bridging Header 파일에 C 헤더 포함**  
Xcode가 생성한 `프로젝트이름-Bridging-Header.h` 파일에 C 헤더를 포함합니다:  

```objc
#import "MyCCode.h"
```

---

### 6. **Swift 코드에서 C 함수 호출**  
`ContentView.swift` 파일에서 C 함수를 호출합니다.  

```swift
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Text("두 수의 합: \(calculateSum(3, 5))")
        .padding()
    }
  }
  
  func calculateSum(_ a: Int, _ b: Int) -> Int {
    return addTwoNumbers(Int32(a), Int32(b))
  }
}
```

---

### 7. **빌드 및 실행**
- 앱을 실행하면, `3 + 5 = 8` 결과가 화면에 표시됩니다.

---

### 주요 개념 정리
1. C 코드 작성 후 **헤더 파일**로 선언해야 Swift에서 사용할 수 있습니다.  
2. Bridging Header는 Swift와 C/Objective-C 코드 간의 연결 역할을 합니다.  
3. Swift에서는 C 함수 호출 시 매개변수와 반환값의 타입을 올바르게 변환해야 합니다.  

---

위 과정을 따라하면 iOS 프로젝트에서 C 코드를 효과적으로 활용할 수 있습니다. 추가적인 도움이 필요하면 알려주세요!

---

