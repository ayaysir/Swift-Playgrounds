# STK Ensemble

https://github.com/user-attachments/assets/fcab9142-670f-4026-a257-19ec9dce263e

이 코드는 **AudioKit**, **STKAudioKit**, 그리고 SwiftUI를 활용하여 세 개의 가상 악기(Flute, Clarinet, Tubular Bells)를 조합한 \*\*음악 합주 시스템(Ensemble Generator)\*\*입니다. 주기적으로 음을 무작위로 선택하여 세 악기가 연주되며, 각 악기의 볼륨을 조절하고, 스케일(Scale)과 전조(Transpose)를 실시간으로 반영할 수 있습니다.

---

## 🔧 주요 구성 요소

### 🧩 STK 악기

* `Flute`, `Clarinet`, `TubularBells`: STKAudioKit의 물리 기반 모델링 악기
* `trigger(note:velocity:)`: 지정한 MIDI 음과 벨로시티로 소리를 내는 메서드
* `stop()`: 악기의 소리를 끈다

### 🔈 Fader

* 각 악기에 대한 볼륨 조절
* `fluteFader`, `clarinetFader`, `bellsFader`는 각각 대응하는 악기를 감싼 Fader
* `.gain`을 통해 실시간 볼륨 조절 가능

### 🎛 Mixer 및 AudioEngine

* `Mixer(fluteFader, clarinetFader, bellsFader)`로 세 악기 음원을 혼합
* `engine.output = mixer`를 통해 최종 출력 연결

### 🔁 CallbackLoop

* `loop = CallbackLoop(frequency:)`는 지정된 주기(Hz)마다 클로저를 실행
* `loop.start()` / `loop.stop()`으로 실행 제어
* 현재 `playRate`가 1.67이면 약 0.6초 간격으로 실행됨

---

## 🎶 음원 생성 로직

```swift
let scale = [60, 62, 64, 66, 67, 69, 71]
```

* MIDI 노트 값으로 C Lydian 스케일

```swift
let transposedScale = [... down + base + up ...]
```

* 전조(`transpose`)를 반영하고,
* 원래 스케일의 뒷부분은 한 옥타브 아래, 앞부분은 한 옥타브 위로 보강하여 음역 확대

```swift
if random(0.45) { flute.trigger(...) }
```

* 악기마다 확률을 다르게 하여 음을 낼지 결정
* 무작위로 노트를 선택하고 `trigger()` 호출
* 벨로시티는 30\~100 사이 무작위 (`randomVelocity()`)

---

## 📌 상태 변수

| 변수             | 설명                         |
| -------------- | -------------------------- |
| `playRate`     | loop 주파수 (Hz 단위, 루프 반복 속도) |
| `scale`        | 현재 사용하는 스케일 (MIDI 음 배열)    |
| `transpose`    | 스케일 전조 값                   |
| `fluteGain`    | 플루트 볼륨                     |
| `clarinetGain` | 클라리넷 볼륨                    |
| `bellsGain`    | 벨 볼륨                       |
| `playingNotes` | 최근 연주된 노트 (악기별)            |

---

## 📝 주요 함수

### `random(_ probability: Double) -> Bool`

* 0\~1 사이 확률로 `true` 반환
  → 연주 유무를 확률적으로 결정하는 데 사용

### `randomVelocity(...)`

* 벨로시티(세기)를 랜덤으로 생성
  → 자연스러운 음색 변화

### `stopAllInstruments()`

* 세 악기를 모두 멈춤 (음이 겹치거나 끊기지 않게 관리)

---

## 🎯 활용 예시

이 클래스를 SwiftUI에서 사용하면,

* 스케일 선택기, 트랜스포즈 슬라이더, 볼륨 조절 노브 등 UI를 통해
  실시간으로 음원을 조작할 수 있음

예:

```swift
Slider(value: $conductor.fluteGain, in: 0...1)
Picker("Scale", selection: $conductor.scale) { ... }
```

---

## ✅ 정리

`STKEnsembleConductor`는 오디오 합성을 위한 **재생 루프**, **확률 기반 음 선택**, **실시간 볼륨 조절**, **스케일 조작**, **STK 악기 연주**를 모두 포함한 오디오 합주 클래스입니다.
음향적으로도, 무작위성과 악기 간의 주파수 분산이 혼합되어 자연스럽고 흥미로운 합주 효과를 만들어 냅니다.
