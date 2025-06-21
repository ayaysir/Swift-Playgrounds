# Reduce vs Body

`@Reducer`를 썼는데도 \*\*`body` 대신 `reduce(into:action:)`\*\*를 구현한 예제는,
**TCA가 `@Reducer`에서 `reduce(into:_:)`를 자동 인식해서 받아들이기 때문**입니다.

즉:

> `@Reducer`에서는 `body`를 쓰는 방식이 일반적이지만,
> **`reduce(into:action:)` 메서드를 직접 구현해도 유효하며 동작합니다.**
> 이는 **TCA가 두 방식을 모두 지원**하기 때문입니다.

---

## ✅ 왜 이렇게 설계됐는가?

TCA의 `@Reducer` 매크로는 다음을 자동으로 수행합니다:

* `@ObservableState`를 통해 상태 타입 지정
* `enum Action`을 추적
* **`reduce(into:_:)`가 존재하면 그것을 리듀서 구현으로 사용**
* 그렇지 않으면 `body`를 사용하여 하위 도메인/리듀서를 구성

---

## ✅ 사용 방식 비교

### 방식 ①: `@Reducer` + `body`

```swift
@Reducer
struct CounterDomain {
  @ObservableState struct State { var count = 0 }
  enum Action { case tap }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .tap:
        state.count += 1
        return .none
      }
    }
  }
}
```

### 방식 ②: `@Reducer` + `reduce(into:action:)`

```swift
@Reducer
struct CounterDomain {
  @ObservableState struct State { var count = 0 }
  enum Action { case tap }

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .tap:
      state.count += 1
      return .none
    }
  }
}
```

🔸 **둘 다 완전히 동일하게 동작합니다.**

---

## ✅ 어떤 걸 써야 하나요?

| 상황                             | 추천                       |
| ------------------------------ | ------------------------ |
| 간단한 도메인                        | `reduce(into:)`가 더 짧고 명료 |
| 하위 도메인(`Scope`)을 조합해야 할 때      | `body` 사용이 자연스러움         |
| 공식 TCA 문서나 DSL 스타일 선호          | `body` 방식                |
| 기존 `ReducerProtocol` 기반 코드 재사용 | `reduce(...)` 그대로 써도 됨   |

---

## ✅ 요약

| 항목                           | 설명                             |
| ---------------------------- | ------------------------------ |
| `@Reducer` + `reduce(into:)` | 허용됨. 간단한 리듀서 작성에 유리            |
| `@Reducer` + `body`          | Scope와 구성 요소가 많은 복잡한 도메인에 적합   |
| 선택 기준                        | 개인 스타일 또는 도메인 구조 복잡도에 따라 선택 가능 |

즉, 예제 코드에서 `@Reducer`와 `reduce(into:)`가 함께 쓰인 것은 **문법적으로 허용되며 자연스러운 조합**입니다.
TCA는 두 방식을 유연하게 허용해 주기 때문에, 상황에 따라 적절히 선택하시면 됩니다.
