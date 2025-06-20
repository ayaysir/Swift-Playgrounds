# Waveform

이 코드는 SwiftUI와 AudioKit, WaveformKit을 활용하여 **오디오 파형을 시각화하고**, 사용자가 **드래그로 재생 범위(start \~ length)를 지정**할 수 있는 인터랙티브한 Waveform 플레이어입니다.
각 구성요소에 대해 **역할과 동작 방식**을 중심으로 자세히 설명드리겠습니다.

---

# ✅ 1. `WaveformConductor`

```swift
class WaveformConductor: ObservableObject, ProcessesPlayerInput
```

### 🔹 역할

* 오디오 재생을 담당하는 AudioKit 기반 오디오 컨트롤러
* `AudioPlayer`, `SampleBuffer`를 설정하고 제공
* UI와 바인딩될 수 있도록 `@Published`를 통해 `samples` 공개

### 🔹 내부 구성

* `AudioEngine`을 통해 오디오 재생 환경 설정
* `player`는 `AudioPlayer`, `.buffer`에 `Cookbook.sourceBuffer(source: .piano)` 를 설정해 `.piano` 샘플을 사용
* `player.isLooping = true` → 오디오 무한 반복
* `createSampleBuffer()`:

  * `AudioBuffer`를 `Float` 배열로 변환해 시각화를 위한 `SampleBuffer` 생성

---

# ✅ 2. `WaveformView`

```swift
struct WaveformView: View
```

### 🔹 역할

* 파형 시각화 및 드래그 UI 포함
* `start`와 `length`를 조절해서 재생 범위 지정
* 실제 오디오 재생은 `conductor`를 통해 수행됨

### 🔹 구성 상태 변수

| 변수          | 설명                         |
| ----------- | -------------------------- |
| `conductor` | 오디오 재생 관리                  |
| `start`     | 선택된 구간의 시작 위치 (0.0 \~ 1.0) |
| `length`    | 선택된 구간의 길이 (0.0 \~ 1.0)    |
| `formatter` | 숫자 표시용 포맷터                 |

---

### 🔸 내부 뷰 구성

#### ① 파라미터 표시

```swift
Text("start: \(start), length: \(length), end: \(start + length)")
```

* 현재 재생 범위 (0.0 \~ 1.0 단위) 표시

#### ② `PlayerControlsII`

```swift
PlayerControlsII(conductor: conductor, source: .piano) { conductor.createSampleBuffer() }
```

* AudioKit Cookbook에서 제공하는 제어용 컨트롤 뷰
* `.piano` 소스를 재생하며, 리셋 버튼 누르면 `createSampleBuffer()` 호출

#### ③ Waveform 파형 시각화 1 (큰 화면)

```swift
ZStack {
  Waveform(samples: conductor.samples)
  MinimapView(start: $start, length: $length)
}
```

* 파형 위에 투명한 사각형(`MinimapView`)을 덮어 드래그 영역 지정 가능

#### ④ Waveform 파형 시각화 2 (선택 영역만 강조)

```swift
Waveform(
  samples: conductor.samples,
  start: Int(start * sampleRangeLength),
  length: Int(length * sampleRangeLength)
)
```

* 위에서 선택된 `start` \~ `length` 범위만 강조해서 보여줌

#### ⑤ 라이프사이클

```swift
.onAppear(perform: conductor.start)
.onDisappear(perform: conductor.stop)
```

* 뷰가 등장하면 오디오 재생 시작, 사라지면 정지

---

# ✅ 3. `MinimapView`

### 🔹 역할

* 사용자가 **드래그로 재생 범위를 선택할 수 있도록** 하는 뷰
* 두 개의 `RoundedRectangle`이 있고:

  * 하나는 **선택된 영역**
  * 하나는 **우측 경계 조절 핸들**

---

### 🔸 주요 상태

| 변수                    | 설명                         |
| --------------------- | -------------------------- |
| `@Binding var start`  | 시작 위치 (WaveformView에서 바인딩) |
| `@Binding var length` | 길이                         |
| `@GestureState`       | 드래그 시작 시 기준값 저장용 상태 변수     |

---

### 🔸 내부 구성

```swift
GeometryReader { geometry in
  RoundedRectangle(...)    // 선택 영역
  RoundedRectangle(...)    // 우측 조절 핸들
}
```

#### 드래그 동작 처리

각 사각형에 `.gesture(dragGesture(...))`를 추가하여 아래와 같이 처리합니다:

```swift
func dragGesture(of mode: DragMode, geometryProxy geometry: GeometryProxy) -> some Gesture
```

| DragMode        | 동작                        |
| --------------- | ------------------------- |
| `.selectedArea` | 사각형 전체를 좌우로 이동 (start 변경) |
| `.handle`       | 우측만 드래그 → length 조절       |

드래그 비율 계산:

```swift
drag.translation.width / geometry.size.width
```

`clamped(to:)`로 `start + length ≤ 1.0` 제약 유지

---

## 🔎 실제 파형 재생 제어는?

현재 `WaveformView`에서 `.onAppear(perform: conductor.start)`로 전체 오디오가 루프 재생되며,
선택된 구간만 **재생하도록 확장하려면** `player.play(from:to:)` 메서드로 `start`와 `length` 기반 구간 재생을 구현해야 합니다 (이전 답변 참고).

---

## ✅ 전체 흐름 요약

```
AudioPlayer.loadBuffer(.piano)
        ↓
SampleBuffer 생성 → WaveformView에 연결
        ↓
Waveform 시각화 + 드래그 제스처로 start/length 조절
        ↓
하단에 선택된 영역 Waveform 강조 표시
        ↓
(.onAppear 시 전체 루프 재생)
```

---
