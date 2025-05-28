# Smooth Delay Operation

이 코드는 **AudioKit**과 SwiftUI를 이용하여 **Smooth Delay 이펙트**를 적용한 오디오 플레이어를 구현한 것입니다. 각 구성 요소가 어떻게 작동하는지 **음향 처리 흐름 중심으로** 자세히 설명드리겠습니다.

---

## 🔧 구조 요약

```swift
class SmoothDelayOperationConductor: ObservableObject, ProcessesPlayerInput
```

* `ObservableObject`: SwiftUI에서 상태 변경을 감지할 수 있도록 함.
* `ProcessesPlayerInput`: `AudioPlayer`를 기반으로 이펙트를 처리한다는 의미의 커스텀 프로토콜.

---

## 📦 `SmoothDelayOperationData`

```swift
struct SmoothDelayOperationData {
  var time: AUValue = 0.1         // 딜레이 시간 (초)
  var feedback: AUValue = 0.7     // 피드백 양 (0.0 ~ 1.0)
  var rampDuration: AUValue = 0.1 // 파라미터 변화 시 부드럽게 변화하는 시간
}
```

* 사용자가 UI에서 조절할 수 있는 딜레이 관련 매개변수를 하나의 구조체로 관리합니다.

---

## 🔊 `@Published var data`

```swift
@Published var data = SmoothDelayOperationData() {
  didSet {
    effect.$parameter1.ramp(to: data.time, duration: data.rampDuration)
    effect.$parameter2.ramp(to: data.feedback, duration: data.rampDuration)
  }
}
```

* `data`가 변경되면 파라미터 1, 2를 **부드럽게 변화(ramp)** 시켜 딜레이 이펙트에 반영합니다.
* `ramp()`는 값이 즉시 튀지 않고 자연스럽게 변화하도록 함.

---

## 🛠 `init()`

```swift
buffer = Cookbook.sourceBuffer(source: "Piano")
player.buffer = buffer
player.isLooping = true
```

* `"Piano"` 샘플 파일을 로드하여 버퍼에 저장하고 `AudioPlayer`에 할당
* 루프 재생 설정

---

## 🔄 `OperationEffect` 정의

```swift
effect = OperationEffect(player) { player, params in
  let delayedPlayer = player.smoothDelay(
    time: params[0],
    feedback: params[1],
    samples: 1024,
    maximumDelayTime: 2.0
  )
  
  return mixer(player.toMono(), delayedPlayer)
}
```

### 🔍 `player.smoothDelay(...)` 설명

* `time`: 딜레이 타임 (param\[0]) — 얼마나 늦게 소리가 반복될지
* `feedback`: 반복되는 소리가 얼마나 강하게 들릴지 (param\[1])
* `samples`: 내부 계산용 샘플 수 (1024개 샘플 단위로 버퍼 처리)
* `maximumDelayTime`: 최대로 허용되는 딜레이 시간 (2초)

### 🎛 `mixer(...)` 의미

* `player.toMono()`: 원본 dry 신호
* `delayedPlayer`: 이펙트가 적용된 wet 신호
  ➡️ 두 신호를 **믹싱하여 출력**합니다.

---

## 🔚 최종 연결

```swift
engine.output = effect
```

* AudioKit 오디오 엔진의 출력은 이 `effect` 노드로 설정됩니다.

---

## 📊 요약

| 구성 요소                      | 역할                                     |
| -------------------------- | -------------------------------------- |
| `AudioPlayer`              | 소스 오디오를 재생 (루프됨)                       |
| `OperationEffect`          | AudioKit의 이펙트 노드로, Smooth Delay 연산을 수행 |
| `parameter1`, `parameter2` | 각각 딜레이 시간과 피드백 비율 제어                   |
| `ramp(to:duration:)`       | 값이 부드럽게 전환되도록 처리                       |
| `engine.output = effect`   | 엔진 출력으로 연결하여 실제 사운드 출력 가능              |

---

## 📣 음향적 특징

* `smoothDelay`: 오디오 버퍼를 내부적으로 샘플 단위로 처리하여 좀 더 **부드러운 반향**을 생성
* `feedback`: 반복되는 에코 효과, 값이 높을수록 리버브처럼 들림
* 딜레이 + 피드백을 이용한 **리듬감, 공간감 생성**에 유용

이 코드는 실시간으로 딜레이 파라미터를 조작할 수 있도록 구성되어 있어 **인터랙티브한 사운드 디자인**에도 적합합니다.

