# Drone Operation

이 코드는 `SporthAudioKit`을 사용해 간단한 **드론(지속음) 사운드**를 만드는 예제입니다. `OperationGenerator`는 **Sporth 기반의 모듈식 신디사이저**로, 사운드를 **코드로 구성**할 수 있는 기능을 제공합니다.

---

## 📌 전체 개요

```swift
let generator = OperationGenerator { ... }
```

* `OperationGenerator`는 하나의 사운드를 만들어 출력하는 객체입니다.
* 클로저 내부에서 정의된 **`OperationParameter`** 들은 Sporth DSL로 변환되어 오디오를 생성합니다.
* 여기선 `drone()`이라는 함수를 통해 **3개의 톤을 반복 재생**하는 소리를 만들어 평균 냅니다.

---

## 🔍 drone 함수 분석

```swift
func drone(frequency: Double, rate: Double) -> OperationParameter {
  let metronome = Operation.metronome(frequency: rate)
  let tone = Operation.sineWave(frequency: frequency, amplitude: 0.2)
  return tone.triggeredWithEnvelope(
    trigger: metronome,
    attack: 0.01,
    hold: 0.1,
    release: 0.1
  )
}
```

### 1. `Operation.metronome(frequency: rate)`

* 일정한 간격으로 트리거 신호를 발생시킵니다.
* `rate`는 1초당 트리거 발생 횟수입니다. (즉, **속도 조절**)
* 예: `rate: 3`이면 1초에 3번 트리거가 발생합니다.

### 2. `Operation.sineWave(...)`

* 지정된 주파수와 진폭으로 사인파 톤을 생성합니다.
* `frequency`: 음의 높이 (Hz)
* `amplitude`: 음의 크기 (여기선 0.2로 약한 소리)

### 3. `triggeredWithEnvelope(...)`

* `tone`을 `metronome`에 의해 트리거되도록 설정합니다.
* **ADSR Envelope** 구조입니다:

| 파라미터      | 설명                |
| --------- | ----------------- |
| `attack`  | 소리가 시작될 때 증가하는 시간 |
| `hold`    | 최대 진폭을 유지하는 시간    |
| `release` | 사운드가 꺼질 때 감소하는 시간 |

즉, **"사인파가 메트로놈 트리거로 짧게 재생되도록 만드는"** 것입니다.

---

## 🎧 최종 결과

```swift
return (
  drone(frequency: 440, rate: 3) // A, 1초에 3번
+ drone(frequency: 330, rate: 5) // E, 1초에 5번
+ drone(frequency: 450, rate: 7) // A♯(B♭), 1초에 7번
) / 3
```

* A(440Hz), E(330Hz), A♯(450Hz)의 세 개 사운드를 반복적으로 재생합니다.
* 각 사운드는 서로 다른 트리거 속도로 실행되며,
* 전체 사운드는 이 3개의 드론을 평균 내어 혼합한 것입니다.
* **결과: 리드미컬하고 유기적으로 맥동하는 배경음** 생성

---

## 🧠 요약

| 요소                      | 설명                   |
| ----------------------- | -------------------- |
| `OperationGenerator`    | 오디오 신호를 동적으로 생성하는 장치 |
| `metronome`             | 트리거 신호 발생            |
| `sineWave`              | 기본적인 음향 생성기          |
| `triggeredWithEnvelope` | 일정 패턴으로 소리를 짧게 재생    |
| `drone(...)`            | 위 로직을 묶은 재사용 가능한 함수  |

---

## 📝 확장 팁

* `frequency`, `rate` 등을 랜덤하게 하거나 `UI`와 연결하면 더 유기적인 사운드가 가능합니다.
* `OperationGenerator`는 `AVAudioUnit`처럼 사용할 수 있어 오디오 체인에도 삽입 가능합니다.

---
