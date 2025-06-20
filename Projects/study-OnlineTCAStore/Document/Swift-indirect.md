# Swift: indirect

`indirect`는 Swift의 열거형(enum)에서 **자기 자신을 재귀적으로 참조할 수 있게 해주는 키워드**입니다.
위 코드에서 `indirect case presented(Action)`은 **자기 자신을 값으로 가질 수 있도록 설정**된 **재귀적 열거형**입니다.

---

## ✅ 왜 `indirect`가 필요할까?

Swift에서 enum은 기본적으로 **값 타입이고, 스택 메모리**에 저장됩니다.
그런데 **열거형의 케이스가 자기 자신을 포함**하려고 하면, **컴파일러가 무한한 크기의 값을 만들 수 없기 때문에 에러가 납니다.**

이 문제를 해결하기 위해 Swift는 **`indirect` 키워드로 힙 메모리에 할당**되도록 하여 재귀를 허용합니다.

---

## ✅ 예시로 보기

### 🔹 재귀적 enum (예: 트리 구조)

```swift
enum Tree {
  case leaf(Int)
  indirect case node(Tree, Tree)
}
```

→ 이건 `Tree.node(Tree, Tree)`처럼 **자기 자신의 인스턴스를 포함하는 구조**이므로 `indirect`가 필요합니다.

---

## ✅ 질문 코드로 돌아가서

```swift
public enum PresentationAction<Action> {
  case dismiss
  indirect case presented(Action)
}
```

여기서 `Action`이 다음과 같은 식으로 또 `PresentationAction`을 포함할 수 있기 때문에, \*\*간접 참조(indirect)\*\*가 필요한 겁니다.

예를 들어:

```swift
enum ProductAction {
  case productTapped(id: UUID)
  case sheet(PresentationAction<DetailAction>)
}

enum DetailAction {
  case close
}
```

이때 내부적으로 계속 중첩될 수 있는 구조가 되기 때문에:

* `PresentationAction` → `presented(Action)` → `Action` 안에 또 다른 `PresentationAction` …
* 이런 식의 **재귀 구조**가 생길 수 있으므로 **`indirect`가 필요**합니다.

---

## ✅ 참고: enum 전체에 `indirect` 지정도 가능

```swift
indirect enum Tree {
  case leaf(Int)
  case node(Tree, Tree)
}
```

위처럼 **enum 자체를 `indirect`로 선언하면**, 모든 케이스가 재귀 가능해집니다.
하지만 성능, 용도 상 **특정 케이스에만 `indirect`를 붙이는 것이 일반적**입니다.

---

## ✅ 요약

| 항목         | 설명                                                |
| ---------- | ------------------------------------------------- |
| `indirect` | enum의 케이스가 자기 자신을 값으로 포함할 수 있도록 허용                |
| 용도         | 재귀 구조 (예: 트리, 중첩된 상태, 프레젠테이션 등)                   |
| 위 코드에서 의미  | `presented(Action)`이 재귀적으로 중첩 가능하므로 `indirect` 필요 |

---

