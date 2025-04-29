# Observable 동작 원리
```plain
viewModel에서 @State를 붙이지 않아도 코드가 동작하는 이유? @Observable 클래스 AudioKit3DViewModel에서 참조하는  각 클래스 AudioEngine3DConductor, SceneCoordinator에 @Observable을 붙이지 않아도 동작하는 이유?
```

## 답변

### 1. `viewModel`에서 `@State`를 붙이지 않아도 코드가 동작하는 이유

`@State`는 SwiftUI 뷰 내부에서 값 타입(보통 구조체)을 **직접 소유**하고 변경할 때 사용됩니다. 그러나 `viewModel`은 클래스(`AudioKit3DViewModel`) 타입이며, 해당 클래스는 SwiftUI 뷰 외부에서 생성되어 참조됩니다. 이 경우 SwiftUI에서 값의 변경을 감지하려면 `@ObservedObject`, `@StateObject`, `@EnvironmentObject` 등의 속성이 필요합니다.

하지만 해당 코드에서는 `@Observable` 속성이 붙어 있는 것으로 보입니다.

Swift 5.9 이상 (또는 Xcode 15 이상)에서는 SwiftUI의 **Observation 프레임워크**를 기반으로 하는 `@Observable` 프로토콜이 도입되었으며, 이 프로토콜을 채택한 객체는 SwiftUI에서 자동으로 상태를 관찰할 수 있습니다. 이를 통해 `@StateObject`나 `@ObservedObject` 없이도 **값의 변경이 뷰에 반영됩니다**.

다시 말해, `viewModel`이 `@Observable`을 따르고 있고, SwiftUI가 이를 알 수 있기 때문에 별도의 속성 래퍼가 필요 없습니다. 단, 이 기능은 Swift의 Observation이 제대로 적용되는 환경(Xcode 15 이상, Swift 5.9 이상, iOS 17 이상 등)에서만 가능합니다.

---

### 2. `AudioEngine3DConductor`, `SceneCoordinator`에 `@Observable`을 붙이지 않아도 되는 이유

`@Observable`은 SwiftUI가 **뷰에서 참조할 값이 변경될 때 UI를 자동 갱신하기 위해 사용하는 것**입니다.

하지만 `AudioEngine3DConductor`와 `SceneCoordinator`는 뷰에서 직접 사용하는 것이 아니라, `AudioKit3DViewModel` 내부에서 사용됩니다. 그리고 이 클래스들은 값의 변경이 SwiftUI 뷰에 **직접적인 영향을 주지 않기 때문에** `@Observable`을 붙일 필요가 없습니다.

즉, 다음과 같은 구조입니다:

- `AudioKit3DView`는 `viewModel: AudioKit3DViewModel`을 소유함
- `AudioKit3DViewModel`은 `@Observable`이라서 값의 변경을 SwiftUI가 감지할 수 있음
- `viewModel` 내부에서 사용하는 `conductor`, `coordinator`는 뷰에 **직접 바인딩된 값이 아님**
- 따라서 그 내부 클래스에 `@Observable`을 붙일 필요가 없음

단, 만약 `AudioEngine3DConductor`나 `SceneCoordinator`의 속성을 뷰에서 **직접 바인딩하거나 관찰**해야 할 경우, 그때는 해당 클래스에도 `@Observable`이나 `@Published` 등을 적용해야 합니다.

---

### 요약

| 항목                          | 이유                                                                 |
|-----------------------------|----------------------------------------------------------------------|
| `viewModel`에 `@State` 없음     | `@Observable`을 통해 SwiftUI가 자동 관찰하므로 별도 속성 래퍼 불필요 |
| `conductor`, `coordinator`에 `@Observable` 없음 | 뷰에서 직접 사용하지 않으며 뷰에 상태 영향을 주지 않기 때문          |


