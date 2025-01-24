`#ifndef`, `#define`, `#endif`는 C와 C++에서 **헤더 파일의 다중 포함 방지(Include Guard)**를 위해 사용됩니다. 이 패턴은 동일한 헤더 파일이 여러 번 포함되었을 때 발생할 수 있는 **중복 정의 문제**를 방지합니다.  

---

### **구조 설명**
```c
#ifndef AddTwoNumbers_h
#define AddTwoNumbers_h 

// 헤더 파일 내용
// 함수 선언, 구조체, 상수 정의 등
int addTwoNumbers(int a, int b);

#endif
```

#### **1. `#ifndef AddTwoNumbers_h`**
- **의미**: "만약 `AddTwoNumbers_h`가 정의되어 있지 않다면"이라는 조건문입니다.
- `AddTwoNumbers_h`가 이전에 정의되지 않았다면, 헤더 파일의 내용을 처리하도록 허용합니다.

#### **2. `#define AddTwoNumbers_h`**
- **의미**: `AddTwoNumbers_h`를 정의합니다.
- 이렇게 정의함으로써 동일한 헤더 파일이 이후에 다시 포함되더라도 중복 처리되지 않습니다.

#### **3. 헤더 파일 내용**
- 헤더 파일에는 보통 함수 선언, 매크로 정의, 구조체 및 상수 정의가 포함됩니다.
- 이 내용은 한 번만 포함되어야 하므로 Include Guard로 보호됩니다.

#### **4. `#endif`**
- **의미**: `#ifndef`로 시작한 조건문을 종료합니다.
- Include Guard 블록의 끝을 나타냅니다.

---

### **왜 필요한가?**
헤더 파일이 여러 번 포함되면, 같은 내용이 중복으로 정의되면서 컴파일 오류가 발생할 수 있습니다. 예를 들어:

#### **중복 포함 문제 예시**
```c
// AddTwoNumbers.h
int addTwoNumbers(int a, int b);

// main.c
#include "AddTwoNumbers.h"
#include "AddTwoNumbers.h" // 중복 포함

int main() {
  return 0;
}
```
위 코드를 컴파일하면 `addTwoNumbers` 함수 선언이 두 번 포함되어 오류가 발생합니다.

#### **Include Guard로 해결**
Include Guard를 사용하면, 동일한 헤더 파일이 중복으로 포함되더라도 **한 번만 처리**되므로 문제가 발생하지 않습니다.

---

### **동작 과정**
1. 헤더 파일이 처음 포함될 때:
   - `AddTwoNumbers_h`가 정의되지 않았으므로 `#ifndef` 조건이 참이 됩니다.
   - 이후 `#define`에 의해 `AddTwoNumbers_h`가 정의되고, 헤더 파일의 내용이 처리됩니다.

2. 헤더 파일이 다시 포함될 때:
   - `AddTwoNumbers_h`가 이미 정의되어 있으므로 `#ifndef` 조건이 거짓이 됩니다.
   - 따라서 헤더 파일의 내용은 무시됩니다.

---

### **대안: `#pragma once`**
`#pragma once`는 Include Guard와 같은 역할을 하지만, 더 간결하게 사용할 수 있습니다.  
예:
```c
#pragma once

int addTwoNumbers(int a, int b);
```
- 대부분의 컴파일러에서 지원되며, Include Guard보다 읽기 쉽고 유지 관리가 간단합니다.  
- 하지만 특정 오래된 컴파일러에서는 지원되지 않을 수 있으므로, Include Guard를 사용하는 경우도 여전히 많습니다.

---

### **결론**
`#ifndef`, `#define`, `#endif`는 헤더 파일이 중복 포함되는 것을 방지하기 위한 표준적인 방식입니다. Include Guard는 코드의 안정성을 높이고, 컴파일 오류를 방지하는 데 필수적입니다.
