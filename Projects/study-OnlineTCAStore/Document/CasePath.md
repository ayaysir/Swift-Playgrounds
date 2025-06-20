# CasePath

\*\*Swift의 `CasePath`\*\*는 열거형(enum)의 **연관 값(associated value)을 추출하거나 삽입하기 위한 경로 개념**입니다.
Swift 표준에는 존재하지 않지만, **[pointfreeco/swift-case-paths](https://github.com/pointfreeco/swift-case-paths)** 라이브러리를 통해 사용할 수 있으며, TCA(The Composable Architecture)에서도 광범위하게 사용됩니다.

---

## ✅ CasePath란?

`CasePath<Root, Value>`는 다음 역할을 합니다:

* **`Root` 열거형에서 특정 `Value`를 꺼내거나 넣을 수 있는 경로**
* Swift의 `KeyPath`가 struct/class의 속성을 추적하는 것과 비슷하지만, `CasePath`는 enum의 **case의 연관 값**을 다룸

---

## ✅ 예제부터 보기

### 🔹 1. 간단한 enum 정의

```swift
enum AppAction {
  case login(username: String)
  case logout
}
```

이때 `login` 케이스에서 username을 추출하고 싶다면?

```swift
import CasePaths

let action: AppAction = .login(username: "Alice")

if let username = (/AppAction.login).extract(from: action) {
  print("로그인한 사용자: \(username)") // 로그인한 사용자: Alice
}
```

### 🔹 2. 삽입도 가능

```swift
let loginAction = (/AppAction.login).embed("Bob")
print(loginAction) // .login(username: "Bob")
```

---

## ✅ CasePath 타입 정의

```swift
struct CasePath<Root, Value> {
  let embed: (Value) -> Root
  let extract: (Root) -> Value?
}
```

* `embed`: `Value` → `Root` (연관 값을 갖는 case를 만든다)
* `extract`: `Root` → `Value?` (enum이 특정 case일 경우 연관 값을 꺼낸다)

---

## ✅ 왜 필요한가?

Swift 기본 `KeyPath`는 **struct/class의 속성에만** 작동하고, **enum의 특정 case를 식별하거나 값을 꺼낼 수 없음**.
그래서 `CasePath`는 다음과 같은 상황에서 매우 유용합니다:

| 상황                         | 사용 이유                                                     |
| -------------------------- | --------------------------------------------------------- |
| TCA에서 하위 도메인의 액션만 추출       | `/Parent.Action.child`                                    |
| switch 없이 특정 케이스 처리        | `.filter { (/MyEnum.someCase).extract(from: $0) != nil }` |
| 네비게이션, UI 상태가 enum으로 표현될 때 | 특정 화면 케이스만 처리할 수 있음                                       |

---

## ✅ CasePath 구문 요약

| 표현                | 의미                           |
| ----------------- | ---------------------------- |
| `/Enum.caseName`  | `CasePath<Enum, 연관값 타입>`을 만듦 |
| `.extract(from:)` | enum이 해당 케이스일 경우 연관 값 추출     |
| `.embed(_:)`      | 연관 값을 받아 enum 케이스로 포장        |

---

## ✅ 예시 2: 중첩 enum

```swift
enum ParentAction {
  case child(ChildAction)
  case logout
}

enum ChildAction {
  case tap
  case toggle(Bool)
}
```

```swift
// ChildAction만 추출
let path = /ParentAction.child
let value = path.extract(from: .child(.tap)) // Optional(.tap)

// embed
let action = path.embed(.toggle(true)) // .child(.toggle(true))
```

---

## ✅ TCA에서 Scope에 사용하는 이유

```swift
Scope(
  state: \.childState,
  action: /ParentDomain.Action.child
) {
  ChildDomain()
}
```

이렇게 하면:

* `ChildDomain.Action` → `ParentDomain.Action.child(...)` 로 감싸서 전달 (`embed`)
* `ParentDomain.Action`에서 `ChildDomain.Action`만 꺼내서 처리 가능 (`extract`)

---

## ✅ 결론

| 항목 | 설명                                                      |
| -- | ------------------------------------------------------- |
| 목적 | enum의 특정 case를 값처럼 다루기 위해                               |
| 장점 | switch 없이 추출/삽입 가능, SwiftUI + TCA에서 강력한 도구              |
| 구현 | 라이브러리 `CasePaths` 필요 (`import CasePaths`)               |
| 문법 | `/Enum.caseName` → `CasePath<Enum, AssociatedValue>` 생성 |

---

