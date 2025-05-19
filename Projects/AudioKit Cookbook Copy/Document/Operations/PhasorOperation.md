# Phasor Operation

이 `generator`는 AudioKit의 `OperationGenerator`를 이용한 **절차적 사운드 생성** 예시입니다. 이 코드는 **랜덤한 피치의 음을 천천히 변화시키며 재생**하고, 여기에 \*\*고전적인 리버브 효과(Chowning Reverb)\*\*를 입혀 **깊이감 있고 예측 불가능한 앰비언트 사운드**를 만듭니다.

아래는 음향 생성 과정 중심으로 단계별 설명입니다.

---

## ✅ 전체 개요

> **목표**: 시간에 따라 변화하는 임의의 MIDI 음을 재생하고, 이를 `Chowning Reverb`로 공간감을 추가하여 믹싱

---

## 🔁 1단계: 시간 기반 위치 생성

```swift
let phasing = Operation.phasor(frequency: 0.5)
```

* **`phasor`**: 0에서 1까지 선형 증가하는 파형 (Sawtooth)
* **frequency: 0.5Hz** → 2초에 한 번 주기
* 사운드 생성 흐름에서 **시간 기반 인덱스** 역할을 함 (0.0 \~ 1.0 사이의 값을 시간에 따라 순차적으로 제공)

---

## 🎲 2단계: 난수 기반 속도 가변화

```swift
* Operation.randomNumberPulse(
    minimum: 0.9,
    maximum: 2,
    updateFrequency: 0.5
  )
```

* phasor 값에 **랜덤한 스케일링**을 적용하여 **음이 얼마나 빠르게 변할지**를 조절
* `updateFrequency: 0.5Hz` → 2초마다 한 번 새로운 랜덤 값 생성
* 결과적으로 phasor의 속도가 매번 조금씩 변동되어 **불규칙한 음의 변화 타이밍**을 유도

---

## 🎵 3단계: MIDI 음 → 실제 주파수로 변환

```swift
let frequency = (floor(phasing * noteCount) * interval + startingNote)
  .midiNoteToFrequency()
```

* `phasing * noteCount` → 0 \~ 24 사이의 float 값
* `floor(...)` → 정수화 → 0 \~ 23 정수
* `* interval + startingNote` → MIDI 음으로 변환 (startingNote: 48 = C3)

  * 예: `0 → 48`, `1 → 50`, ... (2 간격)
* `.midiNoteToFrequency()` → MIDI 음을 Hz 주파수로 변환

👉 최종적으로 시간에 따라 **랜덤한 MIDI 음**이 천천히 순차적으로 선택됨

---

## 🔊 4단계: 오실레이터 생성

```swift
var amplitude = (phasing - 1).portamento()
```

* `phasing - 1` → 0에서 1로 갈수록 -1 → 0 값이 생성됨 (초기값은 음소거)
* `.portamento()` → **부드럽게 변화**시켜 클릭 소리 방지

```swift
var oscillator = Operation.sineWave(
  frequency: frequency,
  amplitude: amplitude
)
```

* 위에서 만든 frequency와 amplitude를 이용해 **사인파 음 생성**
* 매 2초마다 임의의 음이 사인파로 출력됨

---

## 🌫 5단계: 리버브 추가 – Chowning Reverb

```swift
let reverb = oscillator.reverberateWithChowning()
```

* `reverberateWithChowning()`:

  * **John Chowning**의 고전적인 리버브 모델
  * 3개의 **Allpass Filter**, 4개의 **Comb Filter**, 2개의 **Decorrelated Delay Line**을 사용
  * 실제 음향 공간의 반사 특성을 모델링
  * 디지털 방식으로 구현된 **풍부하고 깊은 잔향**

---

## 🎚 6단계: 믹싱

```swift
return mixer(oscillator, reverb, balance: 0.6)
```

* dry (oscillator) : wet (reverb) = 4 : 6 비율로 믹싱
* 리버브가 중심이지만, 원음도 어느 정도 들리는 **자연스러운 공간감** 제공

---

## 📊 음향적 특성 요약

| 구성 요소                        | 설명                           |
| ---------------------------- | ---------------------------- |
| `phasor + random pulse`      | **불규칙한 속도의 시간 흐름** 생성        |
| `floor(phasing * noteCount)` | **MIDI 음 높이 결정**             |
| `sineWave`                   | **기본 사운드 생성기** (부드러운 톤)      |
| `portamento()`               | **클릭 방지용 부드러운 볼륨 변화**        |
| `Chowning Reverb`            | **깊이감 있는 공간 효과**             |
| `mixer`                      | **dry/wet 비율 조절로 톤의 중심성 제어** |

---

## ✅ 요약

이 코드는:

* **불규칙하게 변화하는 음정을 가진 사인파**를
* **클릭 소리 없이 자연스럽게 생성**하고
* **빈티지하면서 깊은 리버브**를 입혀
* **앰비언트 사운드, 백그라운드 음악, 설치음향 등**에 적합한 결과물을 만들어냅니다.

---

# 속도 조절

속도를 느리게 하려면 **음이 바뀌는 속도**를 느리게 조절해야 하며, 이 경우 아래 두 가지 중 **핵심은 `phasor`의 frequency 조절**입니다.

---

## ✅ 1. `phasor(frequency:)` 값을 낮추기 → **가장 직접적인 방법**

```swift
let phasing = Operation.phasor(frequency: 0.5)
```

* `0.5Hz` → 2초에 한 번 cycle이 돎 → 즉, 2초에 한 번 음이 바뀜
* `0.25Hz`로 줄이면 **4초에 한 번 음이 바뀌어** 더 느려짐

### ✅ 예시:

```swift
let phasing = Operation.phasor(frequency: 0.25) // 4초 주기
```

---

## 🔄 2. `randomNumberPulse(updateFrequency:)`는 **변화량 랜덤 주기**에만 영향을 줌

```swift
Operation.randomNumberPulse(minimum: 0.9, maximum: 2, updateFrequency: 0.5)
```

* `updateFrequency`는 **무작위 스케일값이 얼마나 자주 바뀔지**를 정함
* 이것만 줄이면 "속도 자체"보다는 **변화의 무작위성 주기**가 느려질 뿐임

즉, **실제로 음이 바뀌는 템포**를 느리게 하고 싶다면 `phasor(frequency:)` 값을 줄이는 것이 정답입니다.

---

## 🔚 요약

| 변경할 항목                                | 효과                   | 조절 예시              |
| ------------------------------------- | -------------------- | ------------------ |
| `phasor(frequency:)`                  | 음이 바뀌는 **주기 자체** 느리게 | 0.5 → 0.25 → 0.1 등 |
| `randomNumberPulse(updateFrequency:)` | 랜덤값의 **갱신 주기** 느리게   | 0.5 → 0.2 등        |

실제 사운드의 템포를 느리게 만들고 싶다면 \*\*phasor 주파수(frequency)\*\*를 낮추세요.

