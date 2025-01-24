## warning: unexpected C compiler invocation with specified outputs: 

```plain
'/Users/.../Products/Debug-iphoneos/ConnectToNative.app/LeapYear.c' 
(for input: '/Users/.../ConnectToNative/NativeSource/LeapYear/LeapYear.c')
 (in target 'ConnectToNative' from project 'ConnectToNative') 
```

이 경고는 **Xcode에서 C 파일을 빌드하는 과정에서 잘못된 출력 파일 경로 또는 설정**으로 인해 발생합니다. 주요 원인과 해결 방법을 설명드리겠습니다.

---

## **원인**
### **1. C 소스 파일의 잘못된 설정**
- Xcode는 일반적으로 C 소스 파일을 컴파일한 결과를 오브젝트 파일(`.o`)로 출력해야 합니다.  
  위 경고는 C 파일의 빌드 결과를 **앱 번들(`.app`) 내부로 지정하려고 시도**할 때 발생합니다. 이는 잘못된 설정으로 인해 Xcode가 C 파일을 컴파일하고 링크하는 과정에서 예상치 못한 동작을 하게 만듭니다.

### **2. 파일이 잘못된 빌드 단계에 추가됨**
- Xcode 프로젝트에서 `LeapYear.c` 파일이 `Compile Sources` 단계가 아닌, **앱 리소스(`Copy Bundle Resources`) 단계**에 잘못 추가된 경우 발생할 수 있습니다.  
  C 파일은 소스 코드로 컴파일되어야 하며, 리소스로 복사되지 않아야 합니다.

---

## **해결 방법**
### **1. `Compile Sources` 단계 확인**
C 파일이 올바르게 `Compile Sources` 단계에 추가되었는지 확인합니다:

1. **Xcode에서 프로젝트 설정 열기:**
   - **Target** > **Build Phases**로 이동.

2. **Compile Sources 확인:**
   - `Compile Sources` 섹션에 `LeapYear.c`가 포함되어 있는지 확인합니다.
   - 만약 누락되었다면, `+` 버튼을 클릭하여 `LeapYear.c`를 추가합니다.

3. **Copy Bundle Resources에서 제거:**
   - `Copy Bundle Resources` 섹션에서 `LeapYear.c` 파일이 포함되어 있다면 제거합니다.
     - 이 섹션은 앱에 포함될 리소스 파일(이미지, JSON, 스토리보드 등)을 지정하며, 소스 코드 파일은 여기 포함되지 않아야 합니다.

---

### **2. C 파일의 출력 경로 확인**
1. **Custom Output 설정 확인:**
   - `LeapYear.c` 파일이 선택된 상태에서 **File Inspector** (오른쪽 사이드바)를 열고, **Target Membership** 아래에서 잘못된 설정이 있는지 확인합니다.
   - 특별한 출력 경로나 스크립트가 적용되어 있다면 이를 제거합니다.

2. **Derived Data 정리:**
   - 이전 빌드에서 남은 잘못된 출력 파일로 인해 발생할 수도 있으므로, Derived Data를 정리합니다:
     1. **Xcode** > **Settings** > **Derived Data** 경로로 이동.
     2. `DerivedData` 폴더를 삭제하거나, 해당 프로젝트의 데이터를 삭제합니다.

---

### **3. Build Settings 점검**
**Build Settings**에서 C 컴파일러의 동작을 확인합니다:

1. **Target** > **Build Settings**에서 아래 항목을 확인합니다:
   - `Other C Flags`: 불필요한 플래그가 설정되어 있다면 제거합니다.
   - `Compiler for C`: 기본값(`Default Compiler`)으로 설정.

2. C 파일이 특정 스크립트 또는 설정에 의해 앱 번들 경로로 출력되지 않도록 설정을 검토합니다.

---

### **4. 프로젝트 클린 후 다시 빌드**
모든 설정을 정리한 후, 프로젝트를 클린 빌드합니다:
1. **Command + Shift + K**를 눌러 **Clean Build Folder** 실행.
2. 다시 빌드합니다: **Command + B**.

---

### **요약**
이 경고는 주로 C 파일이 `Copy Bundle Resources`에 잘못 추가되었거나, 출력 경로가 앱 번들 내부로 잘못 설정된 경우에 발생합니다. 위 단계를 따라 설정을 수정하면 문제를 해결할 수 있습니다.
