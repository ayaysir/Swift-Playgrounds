# Callback MIDI Instrument

이 코드는 **AudioKit + SwiftUI**를 이용해 MIDI 시퀀서 이벤트를 감지하고 사운드폰트로 소리를 재생하며, 동시에 이벤트 로그를 실시간으로 출력하는 **학습용 인터랙티브 도구**입니다.
핵심 개념은 다음 세 가지입니다:

* `MIDICallbackInstrument`: MIDI 이벤트를 **실시간으로 감지**하여 로그 출력
* `MIDISampler`: MIDI 노트를 **실제로 재생**
* `AppleSequencer`: 시간에 따라 MIDI 노트를 **자동으로 발생**시키는 시퀀서

---

## 📦 클래스 구성: `CallbackInstrumentConductor`

### 🔧 주요 변수

| 변수           | 설명                                   |
| ------------ | ------------------------------------ |
| `engine`     | AudioKit 오디오 엔진                      |
| `sequencer`  | AppleSequencer, 박자/템포 기반으로 노트를 자동 재생 |
| `callbacker` | MIDI 이벤트를 감지하기 위한 콜백 인스트루먼트          |
| `sampler`    | 사운드폰트 기반으로 소리를 출력하는 샘플러              |
| `tempo`      | 템포 (BPM)                             |
| `division`   | 한 마디 내 노트 수 (박자 세분화)                 |
| `text`       | MIDI 이벤트 발생 로그                       |

---

## 🔁 초기화 흐름

```swift
init() {
  setCallback()                             // 콜백 설정
  try sampler.loadSoundFont(...)           // 사운드폰트 로드
  _ = sequencer.newTrack()                 // 클릭 트랙 (이벤트 감지)
  _ = sequencer.newTrack("sound")          // 사운드 트랙 (소리 출력)
  createClickTrack()                       // 노트 생성
  sequencer.setTempo(...)                  // 템포 설정
  engine.output = sampler                  // 출력 설정
}
```

---

## 🧱 `createClickTrack()`: 실제 트랙 생성

* `division` 만큼 루프를 돌면서 노트를 삽입
* `clickTrack`: `callbacker`에게 MIDI를 보내 이벤트 로그를 남김
* `soundTrack`: `sampler`에게 MIDI를 보내 실제 소리 재생

```swift
clickTrack.setMIDIOutput(callbacker.midiIn)
soundTrack.setMIDIOutput(sampler.midiIn)
```

노트는 아래 두 지점에 생성됩니다:

1. **첫 박자 시작 (`firstPosition`)**
2. **중간 박자 위치 (`secondPosition`)**

---

## 🎯 `setCallback()`: 콜백 로직

```swift
self.callbacker = MIDICallbackInstrument { ... }
```

* `.noteOn` 발생 시:

  * 현재 시퀀서 시간 (`self.sequencer.currentPosition.seconds`)과 노트 번호를 로그에 추가

---

## 🖥️ SwiftUI 뷰: `CallbackInstrumentView`

### 주요 UI 구성:

| UI 요소                     | 설명                   |
| ------------------------- | -------------------- |
| `Play`, `Pause`, `Rewind` | 시퀀서 제어               |
| `CookbookKnob`            | 템포 조절                |
| `Slider`                  | division 조절          |
| `ScrollView + Text`       | 콜백 로그 출력 (자동 스크롤 포함) |

### 특징:

* `division`을 변경하면 시퀀서를 멈추고 트랙을 재구성
* 로그는 아래처럼 출력됨:

```
Start Note 60 at 0.0000
Start Note 61 at 0.5000
...
```

* 스크롤은 `.scrollTo("logBottom")`으로 항상 아래로 유지됨

---

## 🧪 Preview

```swift
#Preview {
  CallbackInstrumentView()
}
```

Xcode의 canvas에서 인터랙티브 미리보기 지원

---

## ✅ 요약

| 기능         | 구현 방식                       |
| ---------- | --------------------------- |
| MIDI 노트 생성 | `AppleSequencer`로 자동 반복 생성  |
| 소리 재생      | `MIDISampler` + 사운드폰트       |
| 이벤트 감지     | `MIDICallbackInstrument`    |
| 로그 출력      | SwiftUI `Text` + ScrollView |

---

## 🔧 확장 아이디어

* 각 노트에 따라 다른 소리/색상 출력
* 외부 MIDI 입력과 연동
* division이나 템포 변경 시 실시간 반영
* `.noteOff`도 감지해 note duration 분석
