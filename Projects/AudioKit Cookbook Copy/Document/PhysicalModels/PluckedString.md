# Plucked String

이 코드는 **AudioKit**과 **SoundpipeAudioKit**을 사용하여 *플럭 현악기(plucked string)* 소리를 자동 생성하고, 여기에 **딜레이**와 **리버브** 효과를 적용하는 구조입니다. 아래에 각 구성요소별로 자세히 설명드리겠습니다.

---

## 🔧 주요 구성 요소 설명

### `let pluckedString = PluckedString()`

* SoundpipeAudioKit의 `PluckedString` 노드입니다.
* 실제 기타, 하프 등 줄을 튕기는 소리의 물리적 모델링으로 소리를 생성합니다.
* `trigger()`를 호출하면 소리가 발생합니다.
* `frequency`: 재생될 음의 주파수
* `amplitude`: 음의 크기

### `playRate = 3.0`

* 초당 3번 루프가 반복됨을 의미합니다.
* `CallbackLoop(frequency:)`에서 사용되어, 약 0.33초마다 트리거가 발생합니다.

---

## 🎼 `init()` – 노드 연결 및 효과 설정

1. `DryWetMixer(pluckedString, pluckedString2)`

   * 두 플럭 사운드를 합칩니다.
   * dry/wet 구분 없이 두 음원을 섞는 믹서입니다.

2. `Delay(mixer)`

   * 딜레이 효과 적용
   * `delay.time = 1.5 / playRate` → 약 0.5초 딜레이
   * `delay.feedback = 0.9`: 반복된 신호의 강도가 강함 (잔향 길어짐)

3. `Reverb(delay)`

   * 전체 사운드에 리버브를 걸어 공간감을 추가
   * `dryWetMix = 0.9`: 대부분의 신호를 리버브 처리

4. `engine.output = reverb`

   * 오디오 엔진 출력으로 설정

---

## 🔁 `loop = CallbackLoop(frequency: playRate)`

* 1초에 3번 반복하는 콜백 루프
* 콜백 안에서는 다음이 실행됩니다:

```swift
let scale = [60, 62, 64, 66, 67, 69, 71]
```

* **C 리디안 스케일**입니다.
* `MIDI Note Number`이며 각각 다음과 같습니다:

  * C4, D4, E4, F♯4, G4, A4, B4

```swift
let note1 = Int.random(...)
let note2 = Int.random(...)
```

* 무작위로 두 음 선택 → 두 개의 pluckedString에 할당

```swift
if AUValue.random(...) > 15 {
  pluckedString.trigger()
  pluckedString2.trigger()
}
```

* 확률적으로 50%의 확률로 둘 다 트리거

---

## ✅ `@Published var isRunning`

* SwiftUI와 바인딩되어 있으며, 사용자가 ON/OFF 조작 시 `loop.start()` 또는 `loop.stop()`을 실행

---

## 🧠 요약

| 구성 요소             | 설명                    |
| ----------------- | --------------------- |
| `PluckedString`   | 줄을 튕기는 악기 사운드 생성      |
| `CallbackLoop`    | 일정 주기로 콜백 호출 (음 트리거용) |
| `Delay`, `Reverb` | 공간감 있는 음향 효과 적용       |
| `isRunning`       | 루프 시작/정지 상태           |

이 코드는 **자동으로 리듬감 있게 연주되는 플럭 스트링**을 만들며, 풍부한 잔향과 공간감을 주기 위해 딜레이와 리버브를 결합하여 **앰비언트 음악**이나 **사운드 디자인**에 적합한 사운드를 구성합니다.
