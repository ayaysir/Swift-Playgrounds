# Multitrack MIDI Player

이 코드는 AudioKit을 사용하여 여러 트랙과 악기를 포함한 **MIDI 파일을 재생할 수 있는 SwiftUI 기반의 멀티트랙 MIDI 플레이어**입니다.
구성은 크게 `MultitrackMIDIPlayerConductor`(오디오 및 MIDI 처리 로직)와 `MultitrackMIDIPlayerView`(UI)로 나뉘며, 아래와 같이 작동합니다.

---

## 🎼 `MultitrackMIDIPlayerConductor`: 오디오 및 MIDI 제어 클래스

### 🔹 주요 프로퍼티

```swift
let engine = AudioEngine()
let sampler = MIDISampler()
let sequencer = AppleSequencer()
var samplers: [MIDISampler] = []
var mixer: Mixer!
```

* `AudioEngine`: 오디오 출력의 핵심 객체
* `AppleSequencer`: MIDI 트랙을 다루기 위한 시퀀서
* `samplers`: 트랙별 악기(MIDISampler) 배열
* `mixer`: 여러 sampler를 하나로 합쳐 출력

---

### 🔹 `init()`

```swift
sequencer.loadMIDIFile("MIDI Files/Horde3")
setTracks()
setMixerOutput()
```

앱 시작 시 기본 MIDI 파일(`Horde3`)을 불러오고, 트랙 구성 및 믹서 설정을 실행합니다.

---

### 🔹 `loadMIDIFile(url:)`

```swift
sequencer.loadMIDIFile(fromURL: url)
samplers.removeAll()
setTracks()
setMixerOutput()
```

* `.fileImporter`를 통해 선택한 MIDI 파일을 로드
* 새로운 MIDI 트랙에 맞게 sampler를 재구성하고 믹서도 다시 설정

※ `engine.output = mixer`가 `setMixerOutput()` 안에서 설정되므로 이 라인 이후 오디오 출력이 재설정됨

---

### 🔹 `setTracks()`

```swift
let tracks = sequencer.tracks
...
let sampler = MIDISampler()
try sampler.loadSoundFont(...)
track.setMIDIOutput(sampler.midiIn)
```

각 트랙에 대해:

1. `channel == 9`인지 판단하여 드럼인지 구분
2. `bank` 값을 일반(0) 또는 드럼용(128)으로 설정
3. `programChangeEvents`에서 preset 번호 추출
4. 해당 사운드폰트 로딩
5. 트랙과 sampler 연결 → `track.setMIDIOutput(...)`

로그는 `conductor.midiLog`에 텍스트로 기록됨

---

### 🔹 `sequencerPlay()` / `sequencerStop()`

```swift
sequencer.play()
sequencer.stop()
```

플레이/스톱 버튼에 대응하여 시퀀서를 재생 또는 정지합니다.

---

## 🎛 `MultitrackMIDIPlayerView`: 사용자 인터페이스

### 🔹 상태 바인딩

```swift
@StateObject private var conductor = MultitrackMIDIPlayerConductor()
@State private var showFileImporter = false
```

* `conductor`: 로직을 담당하는 ViewModel
* `showFileImporter`: 파일 가져오기 창 제어용

---

### 🔹 UI 구성 요약

* MIDI 파일명 표시
* \[Load MIDI File], \[PLAY / STOP] 버튼
* MIDI 분석 로그 스크롤 출력

```swift
Text(conductor.fileName)
...
ScrollView {
  Text(conductor.midiLog)
}
```

---

### 🔹 파일 가져오기 (.midi)

```swift
.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.midi]) { result in
  ...
  conductor.loadMIDIFile(url: url)
}
```

유저가 파일을 선택하면 MIDI 파일을 `Conductor`에 전달하여 새롭게 로드합니다.
**보안 스코프 리소스 접근 권한**도 자동으로 획득함 (`startAccessingSecurityScopedResource()`)

---

### 🔹 오디오 엔진 관리

```swift
.onAppear { conductor.start() }
.onDisappear { conductor.stop() }
```

뷰가 등장할 때 AudioKit 엔진 시작, 사라질 때 정지

---

## ✅ 핵심 특징 요약

| 기능         | 구현 방식                                            |
| ---------- | ------------------------------------------------ |
| 트랙별 악기 설정  | `programChangeEvents` 기반으로 `MIDISampler` 생성 및 연결 |
| 퍼커션 채널 감지  | `channel == 9`이면 `bank: 128`로 로딩                 |
| MIDI 분석 출력 | 로그 텍스트를 `ScrollView`에 표시                         |
| 파일 가져오기    | `.fileImporter`를 통해 .mid 파일 로딩                   |
| 실시간 재생 제어  | `sequencer.play()` / `sequencer.stop()` 호출       |

---

## 📦 확장 아이디어

* 트랙별 볼륨/음소거 슬라이더 추가
* ProgramChange 다중 처리 (중간 악기 변경)

