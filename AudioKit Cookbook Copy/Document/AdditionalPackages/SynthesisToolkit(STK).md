# Synthesis Toolkit (STK)

이 코드는 **AudioKit**, **STKAudioKit**, **SwiftUI**를 활용하여 구현된 **셰이커(Shaker) 기반 메트로놈 데모 앱**입니다. 사용자는 템포, 박자, 음색, 벨로시티 등을 조절할 수 있으며, 시각적인 피드백도 함께 제공합니다.
아래는 구조를 전체적으로 설명한 뒤, 구성 요소별로 자세하게 해석해드립니다.

---

## 🧭 전체 개요

* **`STKView`**: 사용자 인터페이스를 담당하는 SwiftUI 뷰
* **`ShakerConductor`**: AudioKit 엔진을 설정하고 Sequencer 및 Shaker를 관리하는 오디오 컨트롤러
* \*\*`SynthesisToolkitView.swift`\*\*는 `STKAudioKit` 기반의 샘플 기반 악기인 `Shaker`를 사용한 오디오 타이머/메트로놈 구현입니다.

---

## 🎼 오디오 구성 (`ShakerConductor`)

```swift
class ShakerConductor: ObservableObject, HasAudioEngine
```

### 구성 요소:

| 속성                   | 설명                                                |
| -------------------- | ------------------------------------------------- |
| `shaker`             | STKAudioKit의 셰이커 악기                               |
| `callbackInstrument` | 비트 타이밍마다 호출되는 콜백 악기                               |
| `reverb`             | 셰이커에 적용할 리버브                                      |
| `sequencer`          | 시퀀서 – 박자 및 타이밍 제어                                 |
| `data`               | 사용자 설정 상태 (`isPlaying`, `tempo`, `currentBeat` 등) |

### 핵심 동작:

* `data`가 바뀔 때마다 `didSet`에서 시퀀서 재시작 + 템포 반영 + 시퀀스 갱신
* `updateSequences()`에서 박자에 따라 셰이커 노트 시퀀스를 생성

```swift
track.sequence.add(...) // 각 박에 음표 추가
```

* `callbackInstrument`는 UI 업데이트용으로 박마다 콜백을 호출

---

## 🧱 SwiftUI 레이아웃 구성 (`STKView`)

### 🌐 Orientation-aware Layout

```swift
let isLandscape = geometry.size.width > geometry.size.height
```

* 화면 비율을 기준으로 **가로/세로 모드**를 판별
* 각 모드에 맞는 HStack/VStack 레이아웃을 다르게 설정

---

## ▶️ PlayButtonArea

* "Start"/"Stop" 토글 버튼
* `GeometryReader`를 통해 버튼을 가운데에 배치

```swift
.position(x: geometry.size.width / 2, y: geometry.size.height / 2)
```

---

## 🎚 TempoSliderArea

```swift
Slider(value: $conductor.data.tempo, in: 60.0...240.0)
```

* 60\~240 BPM 범위 내에서 템포 조절 가능
* 텍스트로 현재 템포 표시

---

## 🎵 BeatSelectArea

* 두 개의 Stepper UI:

  1. **Downbeat** (첫 박자에 나올 음색)
  2. **Other beats** (나머지 박자의 음색)

```swift
conductor.data.downbeatNoteNumber += 1
```

* MIDI 노트 번호를 기반으로 `ShakerType`과 매핑된 음색을 설정함

---

## 🔊 VelocityArea

```swift
Slider(value: $conductor.data.beatNoteVelocity, in: 0...127)
```

* 셰이커의 볼륨 (벨로시티) 조절

---

## 🧮 BeatCounterArea

* 현재 박자 수(`timeSignatureTop`)만큼 버튼이 생성
* 현재 박자는 `data.currentBeat`와 비교해 색상 강조
* 마지막 "+" 버튼을 눌러 박자 수 증가 가능

```swift
GeoCircleButton(...) { conductor.data.timeSignatureTop += 1 }
```

---

## 🟠 GeoCircleButton

```swift
GeometryReader { geometry in
  let fontSize = size * 0.5
```

* **원형 버튼** 안에 텍스트가 동적으로 크기 조절됨
* `.aspectRatio(1, .fit)`로 정사각형 → 원 형태 유지

---

## 🔬 updateSequences()

```swift
track.sequence.add(noteNumber: data.downbeatNoteNumber, ...)
```

* 첫 번째 트랙에 메트로놈 셰이커 노트를 추가
* 두 번째 트랙(콜백 트랙)은 `beat`마다 `CallbackInstrument` 콜백 호출
* `currentBeat` 값을 실시간으로 업데이트하여 UI와 동기화

---

## 📈 FFTView

```swift
FFTView(conductor.reverb)
```

* `AudioKitUI`의 실시간 주파수 스펙트럼 뷰
* `reverb`로 출력된 오디오를 시각화

---

## 🧪 Preview

```swift
#Preview {
  STKView()
}
```

* Xcode canvas에서 실시간 인터랙션 테스트 가능

---

## ✅ 요약

| 구성 요소                    | 역할                   |
| ------------------------ | -------------------- |
| `ShakerConductor`        | 오디오 엔진, 시퀀서, 셰이커 구성  |
| `STKView`                | SwiftUI 기반 UI        |
| `.onAppear/.onDisappear` | 오디오 엔진 시작/종료         |
| `updateSequences()`      | 박자에 따라 음 시퀀스 자동 구성   |
| `GeoCircleButton`        | 박자 표시용 원형 버튼 (터치 가능) |
| `CallbackInstrument`     | 시퀀서와 UI를 연결하는 핵심 콜백  |
| `FFTView`                | 실시간 시각화              |

---
