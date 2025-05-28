# Recorder


이 `Recorder.swift` 파일은 **AudioKit 기반의 녹음 및 재생 기능을 제공하는 SwiftUI 앱 모듈**입니다. 주요 기능은 마이크 입력을 받아 녹음하고, 그 녹음 파일을 재생하는 것입니다. 전체 구조와 각 파트의 역할은 다음과 같습니다:

---

## 🔹 1. `RecorderData` 구조체

```swift
struct RecorderData {
  var isRecording = false
  var isPlaying = false
}
```

* `@Published` 데이터 모델로, 녹음 중인지(`isRecording`)와 재생 중인지(`isPlaying`)를 나타냅니다.

---

## 🔹 2. `RecorderConductor` 클래스

```swift
class RecorderConductor: ObservableObject, HasAudioEngine
```

AudioKit의 오디오 엔진과 노드를 제어하는 **오디오 컨덕터 클래스**입니다.

### 주요 멤버 변수

* `engine`: AudioKit의 `AudioEngine` 인스턴스
* `recorder`: 마이크 입력을 녹음하는 `NodeRecorder`
* `player`: 녹음된 파일을 재생하는 `AudioPlayer`
* `silencer`: `Fader`로, 입력 오디오를 음소거(0dB)하는 역할
* `mixer`: 입력과 재생을 합쳐 최종 출력으로 내보내는 믹서

### `data` 프로퍼티의 역할

* `data.isRecording`이 `true` → 녹음 시작 (`try recorder?.record()`)
* `false` → 녹음 정지 (`recorder?.stop()`)
* `data.isPlaying`이 `true` → `player.load(file:)` 후 재생
* `false` → 정지

### `init()`

* 마이크 입력 노드를 받아 `NodeRecorder`, `Fader`, `AudioPlayer`, `Mixer`를 연결
* `Fader(gain: 0)`를 통해 입력은 실제 출력에는 들리지 않게 처리됨 (무음)

### 노드 연결 상태

`RecorderConductor` 클래스 내 오디오 노드의 연결 상태는 다음과 같습니다:

```
[Microphone Input]
       │
       ▼
    [Fader (gain: 0)]  (silencer, 실제 음은 꺼짐)
       │
       ▼
    [Mixer] ◄──────── [AudioPlayer]  ← (녹음된 파일 재생)
       │
       ▼
  [AudioEngine.output]
```

#### 연결 흐름 요약

1. `engine.input` → `NodeRecorder`에 녹음
2. `engine.input` → `Fader(gain: 0)` → `Mixer`
3. `AudioPlayer` → `Mixer`
4. `Mixer` → `engine.output`


이 구조는 입력(마이크)은 녹음만 하고 출력에는 들리지 않도록 `Fader(gain: 0)`로 차단하며, 녹음된 파일만 `AudioPlayer`를 통해 재생되도록 설계된 것입니다.

---

## 🔹 3. `RecorderView`

```swift
struct RecorderView: View
```

### 구성 요소

* 버튼 1: `"RECORD"` 또는 `"STOP RECORDING"` (녹음 시작/중지)
* 버튼 2: `"PLAY"` 또는 `"STOP PLAYING"` (녹음 파일 재생/중지)
* 마이크 권한이 없을 경우 `"Mic permission required!"` 메시지 표시

### 마이크 권한 확인

* `requestMicrophonePermission { granted in ... }`를 사용해 권한 요청 후 상태 갱신
* 프리뷰에서는 `isPreview` 조건으로 무시됨

---

## 🔹 기타 기능 및 고려 사항

* `Fader`는 실제 녹음은 하되, 소리가 들리지 않도록 하기 위해 gain: 0으로 설정됨
* 녹음 파일은 `NodeRecorder`가 자동 저장
* 재생 시 `player.load(file:)`를 통해 그 파일을 다시 읽어옴
* `@StateObject`로 `RecorderConductor`를 바인딩하여 UI와 연동

---

## ✅ 요약

| 구성 요소               | 역할                       |
| ------------------- | ------------------------ |
| `RecorderConductor` | AudioKit 오디오 녹음/재생 엔진 제어 |
| `RecorderView`      | 녹음/재생 UI 및 마이크 권한 처리     |
| `Fader`             | 입력 음소거 처리                |
| `NodeRecorder`      | 실시간 마이크 오디오를 파일로 녹음      |
| `AudioPlayer`       | 저장된 오디오 파일을 재생           |

이 코드는 **간단한 마이크 녹음기 앱**의 기초 구조를 담고 있으며, AudioKit을 활용한 신호 흐름과 SwiftUI의 상태 바인딩을 효과적으로 활용한 예시입니다.
