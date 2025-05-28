# Telephone

이 코드는 고전 전화기의 키패드 및 음향을 시뮬레이션하는 SwiftUI 기반 앱으로, AudioKit의 `OperationGenerator`를 이용해 다이얼 톤, 벨소리, 통화 중 신호, 그리고 DTMF(이중 음향 다중 주파수; Dual-Tone Multi-Frequency) 톤을 생성합니다. 주요 로직은 `TelephoneConductor` 클래스에 있으며, Sporth(AudioKit의 오디오 DSL)를 사용하여 오디오를 생성합니다.

---

## 🔊 `TelephoneConductor` 클래스 설명

### 구조

* `ObservableObject` 및 `HasAudioEngine`을 채택해 SwiftUI와 AudioKit 환경에 맞게 설계됨.
* `AudioEngine` 인스턴스를 생성해 오디오 노드를 연결하고 재생 제어.

### 📞 주요 사운드 생성기

#### 1. `dialTone`: 기본 전화 대기음

```swift
let dialTone = OperationGenerator {
  let dialTone1 = Operation.sineWave(frequency: 350)
  let dialTone2 = Operation.sineWave(frequency: 440)
  return mixer(dialTone1, dialTone2) * 0.3
}
```

* 350Hz + 440Hz 사인파를 섞은 기본 전화기 "뚜—" 대기음.
* `mixer(...) * 0.3`: 두 사인파를 합친 후 볼륨 조정.

#### 2. `ringing`: 벨소리

```swift
let ringing = OperationGenerator {
  let ringingTone1 = Operation.sineWave(frequency: 480)
  let ringingTone2 = Operation.sineWave(frequency: 440)
  ...
  let ringTrigger = Operation.metronome(frequency: 0.1666)
  ...
}
```

* 480Hz + 440Hz를 2초간 울리고 6초마다 반복하는 구조.
* `Operation.metronome(...)`: 주기적 트리거.
* `triggeredWithEnvelope(...)`: 사운드를 일정 시간 동안 유지하고 끄는 ADSR 방식.

##### triggeredWithEnvelope 

`triggeredWithEnvelope`는 **AudioKit의 `OperationGenerator` 내에서 envelope(진폭 곡선)을 트리거 이벤트에 따라 자동으로 적용**해주는 함수입니다.

```swift
triggeredWithEnvelope(
  trigger: Operation,
  attack: Double,
  hold: Double,
  release: Double
)
```

| 파라미터      | 설명                                                      |
| --------- | ------------------------------------------------------- |
| `trigger` | 0이 아닌 값이 입력될 때 envelope이 시작됨. 주로 `metronome`이나 매개변수를 사용 |
| `attack`  | 신호가 0에서 최대 진폭까지 도달하는 시간 (초)                             |
| `hold`    | 최대 진폭에서 유지되는 시간 (초)                                     |
| `release` | 최대 진폭에서 0까지 떨어지는 시간 (초)                                 |

 * triggeredWithEnvelope는 오디오 신호에 시작-유지-종료 형태의 진폭 곡선(ADSR의 일부)을 자동으로 입히고, 특정 트리거가 들어올 때만 실행되도록 만듭니다. 이로써 시간 제어된 사운드 생성이 가능해집니다.


#### 3. `busy`: 통화 중 신호

```swift
let busy = OperationGenerator {
  let busySignalTone1 = Operation.sineWave(frequency: 480)
  let busySignalTone2 = Operation.sineWave(frequency: 620)
  ...
  let busyTrigger = Operation.metronome(frequency: 2)
}
```

* 480Hz + 620Hz 사인파를 0.25초씩 0.5초 간격으로 반복.

#### 4. `keypad`: 키패드 톤

```swift
let keypad = OperationGenerator {
  let op1 = Operation.sineWave(frequency: Operation.parameters[1])
  let op2 = Operation.sineWave(frequency: Operation.parameters[2])
  let keyPressTone = op1 + op2
  let press = keyPressTone.triggeredWithEnvelope(trigger: Operation.parameters[0], ...)
}
```

* 사용자 입력에 따라 두 주파수를 동적으로 받아 `parameters[1]`, `parameters[2]`로 사인파 생성.
* `parameters[0]`는 트리거 역할을 하며, 눌렀다 뗄 때 구분함.
* `triggeredWithEnvelope`: 짧은 키 톤 재생을 위해 공격-유지-릴리스 구조.

---

### 기타 기능

* `last10Digits`: 최근 입력한 키 10자리 유지.
* `doit(key:state:)`: 각 키에 대한 반응을 정의. `"CALL"`, `"BUSY"` 등 특별 키와 숫자 키를 구분 처리.
* `init()`:

  * `keys`: 각 숫자에 해당하는 DTMF 주파수를 정의 (예: `"1"` = 697Hz + 1209Hz).
  * `engine.output`: 출력 믹서 설정.

---

## 📱 `TelephoneView` 간단 설명

* SwiftUI 기반 UI 구성.
* `NumberKeyInfo`: 키패드의 숫자 및 문자 정보 구조체.
* `LazyVGrid`: 전화기 키패드 형태로 버튼 정렬.
* 각 키는 `.gesture`를 통해 눌림/떼짐 이벤트 감지 및 `conductor.doit(...)` 호출.
* `PhoneKey`, `BusyKey`, `DeleteKey`: 각각 통화 시작, 종료, 삭제 역할의 버튼 구성.

---

## 결론

이 코드는 SwiftUI와 AudioKit의 `OperationGenerator` + Sporth 문법을 조합하여 실제 전화기처럼 작동하는 인터랙티브 사운드 앱을 구현한 예시입니다.

* `OperationGenerator`는 저수준 DSP 코드 없이 오디오 신호 처리를 구현할 수 있게 해줍니다.
* `triggeredWithEnvelope`, `metronome`, `parameters`는 동적 오디오 제어를 위한 핵심 Sporth 연산자입니다.

---
