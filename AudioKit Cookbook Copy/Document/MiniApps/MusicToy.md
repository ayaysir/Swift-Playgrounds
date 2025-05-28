
# Music Toy

이 `MusicToy.swift` 코드는 AudioKit 기반의 음악 장난감 앱 예제입니다. 사용자가 사운드를 선택하고 템포, 필터, 볼륨 등을 조절하여 아르페지오, 코드, 베이스, 드럼 사운드를 재생할 수 있는 인터랙티브한 SwiftUI 앱입니다. 아래에 전체적인 구조와 핵심 내용을 **구조별로** 정리해드리겠습니다.

---

## ✅ 전체 구조 요약

| 구성                  | 내용                                                              |
| ------------------- | --------------------------------------------------------------- |
| `MusicToyData`      | 사용자 조작에 따라 변하는 상태값(볼륨, 사운드 종류, 필터 등)을 저장하는 모델                   |
| `MusicToyConductor` | AudioKit 엔진 및 시퀀서/샘플러/필터를 구성하고 상태 변경 시 반응하여 오디오 처리              |
| `MusicToyView`      | SwiftUI 뷰. UI 컨트롤(버튼, 피커, 노브)을 통해 사용자 입력을 받고 `MusicToyData`에 반영 |

---

## 📦 1. `MusicToyData`

```swift
struct MusicToyData {
  var isPlaying: Bool = false
  var bassSound: Sound = .square
  ...
  var filterFrequency: Float = 1.0
  var length: Int = 4
}
```

* 사용자 설정값을 저장하는 **모델 구조체**입니다.
* SwiftUI 뷰의 바인딩에 사용되며, 값이 변경되면 `MusicToyConductor`에서 오디오 설정을 업데이트합니다.
* `Sound`는 `square`, `saw`, `pad`, `noisy` 타입이며, 이는 `.exs` 사운드폰트 파일로 연결됩니다.

---

## 🎛️ 2. `MusicToyConductor`: 오디오 처리 담당

### 핵심 요소

```swift
var engine = AudioEngine()
var sequencer: AppleSequencer!
var arpeggioSynth = MIDISampler()
var padSynth = MIDISampler()
var bassSynth = MIDISampler()
var drumKit = MIDISampler()
var filter: MoogLadder?
```

* AudioKit의 주요 컴포넌트들을 선언
* `filter = MoogLadder(mixer)`를 통해 모든 사운드를 하나의 믹서로 묶고, Moog 스타일 필터를 걸어 출력

### 초기화

```swift
useSound(.square, synth: .arpeggio)
useSound(.saw, synth: .pad)
useSound(.saw, synth: .bass)
```

* 처음에는 정해진 사운드로 초기화
* 드럼은 `drumSimp.exs` 사운드폰트 로딩

### 시퀀서 설정

```swift
sequencer = AppleSequencer(fromURL: demoMIDIURL)
sequencer.enableLooping()
sequencer.tracks[1].setMIDIOutput(arpeggioSynth.midiIn)
...
```

* MIDI 파일을 불러와서 각각의 트랙을 해당 샘플러와 연결

### 상태 동기화

```swift
@Published var data = MusicToyData() {
  didSet {
    updateSounds()
  }
}
```

* `data` 값이 바뀌면 `updateSounds()` 호출됨
* 음색, 볼륨, 필터, 템포 등 변경 사항을 반영

### 주요 메서드

* `adjustFilterFrequency(_:)`: 필터 컷오프 주파수를 0.0 ~ 1.0 → 30Hz ~ 20kHz로 변환해 설정
* `adjustVolume(_:instrument:)`: 각 악기의 볼륨 설정
* `setLength(_:)`: 루프 길이 변경
* `useSound(_:synth:)`: `.exs` 사운드폰트 파일을 샘플러에 로딩

---

## 🎹 3. `MusicToyView`: 사용자 인터페이스

* SwiftUI 기반의 컨트롤들을 통해 사용자 입력을 받음
* 값은 `conductor.data`에 바인딩되어 즉시 반영됨

### 상단 제어

* `isPlaying`: Play / Stop 버튼으로 시퀀서 재생 제어
* `rewindSequence()`: 되감기
* `length`: 루프 길이(박자 수)

### 중간 제어

* `CookbookKnob`: 템포, 필터 주파수 노브
* 사운드 선택 Picker: 아르페지오, 코드, 베이스 음색

### 하단 제어

* 각 악기 볼륨을 0.5\~1.0 범위에서 조절 가능

---

## 🎵 예시 사용 흐름

1. 사용자가 Tempo 노브를 140으로 돌리면:

   * `data.tempo` 변경
   * `adjustTempo(140)` 호출 → 시퀀서 템포 갱신

2. 아르페지오 음색을 `.saw`로 선택하면:

   * `.exs` 사운드파일 로딩 (`useSound`)

3. 필터 주파수를 0.2로 내리면:

   * `30Hz~20000Hz` 범위 중 저역에 가까운 주파수가 선택되어 고역이 감쇠됨

---

## 🧠 기술적 특징 요약

| 기술 요소                                 | 설명                           |
| ------------------------------------- | ---------------------------- |
| AudioKit                              | 오디오 처리 전반 (시퀀서, 필터, 샘플러, 믹서) |
| `MoogLadder`                          | 고품질 아날로그 시뮬레이션 필터            |
| `.denormalized(to:taper:)`            | 0.0\~1.0 값을 로그 스케일로 주파수로 변환  |
| `AppleSequencer`                      | MIDI 기반 시퀀서로 루프, 재생 가능       |
| SwiftUI `@StateObject` + `@Published` | UI ↔ AudioKit 상태 양방향 연동      |

---
