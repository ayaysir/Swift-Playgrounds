# Pitch Shift Operator

이 코드는 **`AudioKit` 프레임워크**를 활용해, 하나의 오디오 음원에 **피치 쉬프팅(Pitch Shifting)** 이펙트를 주고, 원본과 이펙트 신호를 **믹싱하여 출력**하는 과정을 다룹니다. 주요 클래스는 `PitchShiftOperationConductor`입니다.

---

## 📦 전체 구성 흐름 요약

```
AVAudioBuffer (음원)
   ↓
AudioPlayer (루프 재생)
   ↓───────┐
           └─────▶ OperationEffect (피치 쉬프팅 처리)
                        ↓
              DryWetMixer (원본/이펙트 믹스)
                        ↓
                  AudioEngine.output
```

---

## ✅ 1. `PitchShiftOperationData` 구조체

```swift
struct PitchShiftOperationData {
  var baseShift: AUValue = 0
  var range: AUValue = 7
  var speed: AUValue = 3
  var rampDuration: AUValue = 0.1
  var balance: AUValue = 0.5
}
```

| 항목             | 설명                                                  |
| -------------- | --------------------------------------------------- |
| `baseShift`    | 기본 피치 시프트 양 (세미톤 단위, 예: +12는 한 옥타브 위)               |
| `range`        | 진동의 범위 (진폭) — `sin` 곡선의 위아래 피치 이동 폭                 |
| `speed`        | 피치를 흔드는 속도 — 초당 몇 번 흔들릴지 (주파수)                      |
| `rampDuration` | 파라미터 값이 바뀔 때 얼마나 부드럽게 변화할지                          |
| `balance`      | Dry/Wet 믹스 비율. `0 = 원본만`, `1 = 이펙트만`, `0.5 = 절반 믹스` |

> 📝 **ramp**: 오디오에서는 어떤 값을 "서서히" 바꾸는 것을 의미.
> 예: 갑자기 바꾸면 튀므로 `0.1초` 동안 점진적으로 바꿈.

---

## ✅ 2. `PitchShiftOperationConductor` 클래스

### 주요 객체

```swift
let engine = AudioEngine() // 전체 오디오 처리 엔진
let player = AudioPlayer() // 버퍼 재생기
let pitchShift: OperationEffect // 피치 쉬프팅 이펙트
let dryWetMixer: DryWetMixer // 원본과 이펙트를 믹싱
let buffer: AVAudioPCMBuffer // 오디오 데이터를 담고 있음
```

---

### 🔷 버퍼 및 플레이어 설정

```swift
buffer = Cookbook.sourceBuffer(source: "Piano")
player.buffer = buffer
player.isLooping = true
```

* `"Piano"`라는 이름의 오디오 파일을 로딩하고,
* 무한 반복으로 재생 설정

---

### 🔷 OperationEffect로 피치 쉬프팅 정의

```swift
pitchShift = OperationEffect(player) { player, params in
  let sinusoid = Operation.sineWave(frequency: params[r(3)])
  let shift = params[r(1)] + sinusoid * params[r(2)] / 2.0
  return player.pitchShift(semitones: shift)
}
```

#### 설명

| 코드                                    | 설명                                             |
| ------------------------------------- | ---------------------------------------------- |
| `params[r(1)]`                        | baseShift                                      |
| `params[r(2)]`                        | range                                          |
| `params[r(3)]`                        | speed                                          |
| `Operation.sineWave(...)`             | 주어진 주파수로 사인파 생성 (피치를 위아래로 흔드는 기반 신호)           |
| `shift = base + sine * range / 2`     | 사인 곡선의 값이 -1 \~ 1 사이이므로 `range/2`를 곱해 전체 범위 조절 |
| `player.pitchShift(semitones: shift)` | 최종적으로 실시간으로 피치를 흔듦                             |

---

### 🔷 초기 파라미터 값 설정

```swift
pitchShift.parameter1 = 0    // baseShift
pitchShift.parameter2 = 7    // range
pitchShift.parameter3 = 3    // speed
```

---

### 🔷 Dry/Wet Mixer 설정

```swift
dryWetMixer = DryWetMixer(player, pitchShift)
engine.output = dryWetMixer
```

* 원본 `player`와 이펙트가 적용된 `pitchShift`의 신호를 믹싱함
* `balance` 값에 따라 둘 중 어떤 비율로 출력할지를 조절

---

### 🔷 외부에서 슬라이더 등으로 조절할 수 있게

```swift
@Published var data = PitchShiftOperationData() {
  didSet {
    pitchShift.$parameter1.ramp(to: data.baseShift, duration: data.rampDuration)
    pitchShift.$parameter2.ramp(to: data.range, duration: data.rampDuration)
    pitchShift.$parameter3.ramp(to: data.speed, duration: data.rampDuration)
    dryWetMixer.balance = data.balance
  }
}
```

* SwiftUI에서 `data`가 바뀔 때마다 이펙트 파라미터를 실시간 업데이트
* `ramp(to:duration:)`로 값을 부드럽게 전환

---

## 🎧 사운드 처리 흐름 (음향적으로)

1. `AudioPlayer`가 원본 음원을 재생
2. `OperationEffect`가 사인파 기반의 시간 변화에 따라 피치를 위아래로 진동시킴

   * 결과적으로 **비브라토(vibrato)** 같은 효과가 생성됨
3. `DryWetMixer`가 원본과 이펙트 음을 섞음
4. 최종적으로 `AudioEngine`에서 소리를 출력

---

## ✅ 요약

| 요소                    | 역할                        |
| --------------------- | ------------------------- |
| `AudioPlayer`         | 원본 오디오를 재생                |
| `OperationEffect`     | 피치를 흔드는 이펙트를 실시간 적용       |
| `DryWetMixer`         | 원본 + 이펙트 비율을 믹싱           |
| `@Published var data` | SwiftUI와 연동되는 이펙트 조절 슬라이더 |
| `ramp(...)`           | 매끄러운 값 변화 제공              |

이 코드는 AudioKit을 활용한 **모듈식 사운드 디자인**의 전형적인 예시로, 사용자가 실시간으로 피치 변화 속도, 범위 등을 조절할 수 있어 **창의적 음향 실험**에 매우 적합합니다.
