# Instrument Operation

`InstrumentOperationConductor`는 **SporthAudioKit**을 사용하여 간결한 코드로 복잡한 **음향 합성 로직**을 구현한 `ObservableObject` 클래스입니다. 이 클래스의 핵심은 `OperationGenerator`를 통해 **FM 신스와 리듬 기반 트리거, 그리고 리버브 공간 처리**를 결합한 **절차적 악기 연주**를 구성하는 데 있습니다.

---

## 🎛 구조 요약

```swift
class InstrumentOperationConductor: ObservableObject, HasAudioEngine
```

* `ObservableObject`이므로 SwiftUI에서 `@StateObject`로 사용할 수 있습니다.
* `HasAudioEngine` 프로토콜을 통해 AudioKit의 `engine`을 직접 제어합니다.

---

## 🎼 OperationGenerator 내부 설명

```swift
let generator = OperationGenerator { ... }
```

이 클로저는 Sporth DSL을 Swift 스타일로 구성한 것으로,
최종적으로 `Operation`의 signal graph를 생성합니다.

---

### 🔹 `func instrument(...)` 설명

```swift
func instrument(noteNumber: MIDINoteNumber, rate: Double, amplitude: Double) -> OperationParameter
```

이 함수는 하나의 악기 역할을 합니다.

#### 내부 동작:

```swift
let metronome = Operation.metronome(frequency: 82 / (60 * rate))
```

* `metronome`은 **트리거 신호**를 일정 간격으로 발생시키는 Sporth의 `metro` 연산자에 해당합니다.
* BPM이 82일 때, 지정된 `rate`에 따라 일정한 시간마다 발동함.
* `rate`는 음 하나가 몇 배 빠르거나 느리게 연주될지를 조절하는 비율 값
  * `rate = 1`이면 기본 템포 그대로
  * `rate = 2`이면 템포 절반 (느리게)
  * `rate = 0.5`이면 템포 두 배 (빠르게)

##### 예제

| `rate` 값 | 계산식                       | metronome 주파수 | 초당 트리거 횟수 | 결과     |
| -------- | ------------------------- | ------------- | --------- | ------ |
| `1`      | 82 / (60 × 1)             | ≈ 1.3667 Hz   | ≈ 1.37회   | 느리게 반복 |
| `2`      | 82 / (60 × 2)             | ≈ 0.6833 Hz   | ≈ 0.68회   | 더 느리게  |
| `4`      | 82 / (60 × 4)             | ≈ 0.3416 Hz   | ≈ 0.34회   | 매우 느리게 |
| `0.5`    | 82 / (60 × 0.5) = 82 / 30 | ≈ 2.733 Hz    | ≈ 2.73회   | 빠르게 반복 |


```swift
let frequency = Double(noteNumber.midiNoteToFrequency())
```

* `MIDINoteNumber` → Hz 주파수로 변환

```swift
let fmOsc = Operation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)
```

* Sporth의 `fm` 연산자에 해당 (주파수 변조 발진기)
* Carrier wave를 Modulator wave로 변조하여 보다 복잡한 스펙트럼을 생성합니다.
* fmOscillator는 FM(Frequency Modulation) 방식의 오실레이터입니다.
  * FM 합성(FM Synthesis) 을 기반으로 하며, 입력된 `baseFrequency와` `amplitude` 값을 바탕으로 소리를 생성합니다.

```swift
return fmOsc.triggeredWithEnvelope(trigger: metronome, attack: 0.5, hold: 1, release: 1)
```

* `triggeredWithEnvelope`는 Sporth에서 `trig` + `adsr` 조합에 해당
* 트리거가 발생할 때마다 FM 사운드가 **0.5초에 걸쳐 올라갔다가, 1초 유지되고, 1초에 걸쳐 감소**합니다.

---

### 🔹 여러 음의 합성

```swift
let instruments2 = [
  instrument(noteNumber: 60, rate: 4, amplitude: 0.5),
  instrument(noteNumber: 62, rate: 5, amplitude: 0.4),
  instrument(noteNumber: 65, rate: 7, amplitude: 1.3 / 4.0),
  instrument(noteNumber: 67, rate: 7, amplitude: 0.125),
].reduce(Operation.trigger) { $0 + $1 } * 0.13
```

* 네 개의 `instrument(...)` 호출로 다양한 음과 리듬을 만들어냅니다.
* `reduce(Operation.trigger)`는 처음에 더미 트리거 (`Operation.trigger`, 즉 0값)로 시작해서 하나씩 더해 합산된 signal graph를 구성합니다.
* 마지막에 `* 0.13`으로 전체 볼륨을 조절합니다.

---

### 🔹 리버브 적용

```swift
let reverb = instruments2.reverberateWithCostello(feedback: 0.9, cutoffFrequency: 10000).toMono()
```

* Sporth의 FDN(Finite Delay Network) 리버브 모델인 `costello`를 사용
* 8개의 딜레이 라인을 이용한 고품질 리버브 모델입니다.
* `feedback: 0.9`: 긴 잔향을 의미하며 홀 같은 공간감을 연출
* `cutoffFrequency: 10000`: 10kHz 이하의 신호만 통과 (고역 감쇠로 더 자연스러운 리버브)

```swift
return mixer(instruments2, reverb, balance: 0.4)
```

* `dry` (원본 신호)와 `wet` (리버브 신호)를 0.4의 비율(wet이 0.4)로 믹싱합니다.

---

## 🔊 Sporth 관점 요약 (예상 변환)

```sporth
// 각각의 note
fm freq=261.63 amp=0.5 trig=metro(82/240) trigadsr(0.5, 1, 1) *
+
...
costello feedback=0.9 hpcf=10000
mix dry wet balance=0.4
```

---

## 🔈 음향적 설명

* 이 코드는 **FM 합성**을 기반으로 다양한 주파수의 음을 **불규칙한 간격**으로 발생시킵니다.
* 각 음은 `attack-hold-release` envelope을 갖기 때문에 자연스럽고 **감정적인 연주 스타일**을 시뮬레이션합니다.
* 리버브는 매우 큰 공간감을 제공하므로, **배경음악, 설치예술, 앰비언트 사운드** 등에 적합한 느낌을 줍니다.

---

## ✅ 요약

| 구성 요소                     | 설명                                           |
| ------------------------- | -------------------------------------------- |
| `OperationGenerator`      | Sporth DSL 기반의 사운드 생성 엔진                     |
| `instrument(...)`         | FM 사운드 + 리듬 트리거 + envelope                   |
| `reverberateWithCostello` | 고급 리버브로 공간감 추가                               |
| `mixer(...)`              | dry/wet 사운드 믹싱                               |
| 전체 목적                     | 다양한 피치와 템포의 FM 톤을 자동 생성하고 리버브를 더해 풍부한 배경음 생성 |

이 구조는 AudioKit에서 **음향 알고리즘 프로토타이핑**이나 **창작적 사운드 디자인**에 매우 유용하게 활용됩니다.

