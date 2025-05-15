# Crossing Signal

`CrossingSignalConductor` 클래스는 **AudioKit** 프레임워크를 이용해 **영국식 횡단보도 경고음**(Crossing Signal Tone)을 생성하고 제어하는 역할을 합니다. 이 클래스는 `ObservableObject`와 `HasAudioEngine`을 채택하여 SwiftUI에서 오디오 처리를 UI와 연동할 수 있게 설계되어 있습니다. 아래에서 해당 클래스의 **각 구성 요소를 라인별로 분석**하고, 그 **음향적 의미**도 함께 설명합니다.

---

## 🔧 클래스 선언

```swift
class CrossingSignalConductor: ObservableObject, HasAudioEngine
```

* `ObservableObject`: SwiftUI에서 이 객체의 속성이 변경되었을 때 UI를 갱신할 수 있도록 함.
* `HasAudioEngine`: `AudioKit`에서 `engine` 속성을 기본으로 제공하도록 하는 프로토콜로, 오디오 신호 흐름을 관리할 수 있게 함.

---

## 🎛 오디오 엔진

```swift
let engine = AudioEngine()
```

* `AudioEngine`: AudioKit의 핵심 클래스. 노드를 연결하고 재생하는 **신호 처리 그래프** 역할을 함.
* 이 `engine`은 내부적으로 AVAudioEngine을 추상화하고 있으며, `generator`를 output에 연결하여 사운드 출력을 제어함.

---

## ▶️ 실행 상태 제어

```swift
@Published var isRunning = false {
  didSet {
    isRunning ? generator.start() : generator.stop()
  }
}
```

* `@Published`: SwiftUI View에서 상태 변화 감지용.
* `isRunning`이 `true`가 되면 `generator`를 시작하고, `false`이면 멈춤.
* UI 버튼을 통해 이 값을 토글할 수 있음.

---

## 🔉 OperationGenerator (신호 생성기)

```swift
let generator = OperationGenerator {
  ...
}
```

* `OperationGenerator`: AudioKit의 고수준 신호 생성기로, Sporth 언어 기반 DSL로 신호를 구성함.
* 내부 클로저에서 오디오 신호 처리 체인을 정의함.

---

## 📡 사운드 구성 상세

```swift
let crossingSignalTone = Operation.sineWave(frequency: 2500)
```

* **2500Hz 사인파**를 생성.
* 매우 높은 주파수로, 실제 영국 횡단보도에서 청각장애인을 위한 경고음에 가까운 주파수임.

---

```swift
let crossingSignalTrigger = Operation.periodicTrigger(period: 0.2)
```

* **0.2초마다 트리거**를 발생.
* 1초에 5번의 주기로 사운드를 깜빡임 (일종의 깜빡이는 경고음 효과).

---

```swift
let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
  trigger: crossingSignalTrigger,
  attack: 0.01,
  hold: 0.1,
  release: 0.01
)
```

* 트리거가 발생할 때마다 사인파를 **ADSR envelope**으로 감싸서 짧게 발음.
* **attack: 0.01초** (빠르게 시작)
* **hold: 0.1초** (약 0.1초 동안 유지)
* **release: 0.01초** (빠르게 소멸)

⏳ → 이 구조는 실제 횡단보도 경고음의 **"삐-삐-삐"** 패턴을 만들기 위한 구조입니다.

---

```swift
return crossingSignal * 0.2
```

* 전체 음량을 줄임 (20%로).
* 고주파 음이므로 귀에 자극적일 수 있어 음량을 낮춤.

---

## 🔌 init()

```swift
init() {
  engine.output = generator
}
```

* AudioEngine의 출력 노드를 `generator`로 설정.
* 즉, generator에서 생성된 소리가 최종 출력으로 이어짐.

---

## 📈 음향적 관점 요약

| 구성 요소                | 역할                          |
| -------------------- | --------------------------- |
| Sine Wave 2500 Hz    | 고주파의 청각 경고음 생성              |
| Periodic Trigger     | 일정 간격(0.2s)으로 신호 발생         |
| ADSR Envelope        | 음을 짧게 트리거하여 "삐-삐" 같은 경고음 형성 |
| Volume Scaling (0.2) | 음량 제한하여 자극 최소화              |

이런 구조는 실제 **철도 건널목**, **횡단보도** 등의 **보행자 경고음 시뮬레이션**에 적합합니다.

---

## 📦 요약

`CrossingSignalConductor`는:

* AudioKit의 `OperationGenerator`를 통해 2500Hz의 고주파 사인파를 생성하고
* 주기적인 트리거와 envelope를 통해 점멸하는 듯한 짧은 경고음을 만들며
* SwiftUI와 연동 가능한 형태로 설계되어 있습니다.

이 구현은 **Andy Farnell의 "Designing Sound"** 에서 영감을 받은 것으로, 실제 세계의 사운드를 디지털로 **모사(simulate)** 한 전형적인 예입니다.
