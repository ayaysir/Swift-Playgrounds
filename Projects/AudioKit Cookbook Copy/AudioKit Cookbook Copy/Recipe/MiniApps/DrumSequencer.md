# Drum Sequencer

이 `DrumSequencerConductor` 클래스는 AudioKit과 SwiftUI를 활용한 드럼 시퀀서 로직을 담당하며, 기본적인 구조와 기능은 다음과 같습니다:

---

## 📦 클래스 개요

```swift
@Observable
class DrumSequencerConductor: ObservableObject, HasAudioEngine
```

- `ObservableObject`이므로 SwiftUI 뷰와 바인딩 가능.
- `@Observable`은 상태 변화를 자동 감지하여 뷰 갱신을 가능하게 함 (Swift Macros).
- `HasAudioEngine`은 `engine`을 제공하는 AudioKit 프로토콜.

---

## 🧠 주요 프로퍼티

| 프로퍼티       | 설명 |
|----------------|------|
| `engine`       | AudioKit의 오디오 엔진 |
| `drums`        | MIDI 샘플러로, 드럼 소리를 낼 수 있음 |
| `midiCallback` | 시퀀서에서 재생된 MIDI 노트를 실제 소리로 바꿔주는 콜백 |
| `sequencer`    | MIDI 파일을 기반으로 재생 가능한 AppleSequencer 인스턴스 |
| `tempo`        | 현재 BPM (변경 시 실시간 반영됨) |
| `isPlaying`    | 재생 상태 (`true`면 재생, `false`면 정지) |
| `hiHatsRoll`   | 하이햇 패턴의 시각화 문자열 (🟩와 ⬜️로 표시됨) |

---

## 🥁 기능 설명

### 🎵 `init()`

초기화 시 다음 작업을 수행합니다:

1. MIDI 노트 콜백 설정 → `drums.play(...)`로 음 재생.
2. 샘플 오디오 파일 로드 → `drums.loadAudioFiles(audioFiles!)`
3. 시퀀서 초기 설정:
   - MIDI 출력 연결, 루프 설정, 템포 설정
   - 트랙별 노트 추가 (총 4트랙)
     - 트랙 0, 1: 베이스 드럼
     - 트랙 2: 하이햇 (8비트 패턴)
     - 트랙 3: 스네어
4. 하이햇 시각화 업데이트

---

### 🧪 `randomizeHiHats()`

- 트랙 2의 기존 노트를 제거한 후
- 새로운 16개의 하이햇 노트를 생성합니다 (1마디 분량)
  - 음높이: 30 또는 31 (랜덤)
  - 세기: 80~127 (랜덤)
  - 위치: 0부터 15까지 16분음표 단위
  - 길이: 0.5 비트 (짧은 소리)
- `updateHiHatsRoll()` 호출로 UI 반영

---

### 🟩 `updateHiHatsRoll()`

- 트랙 2에 있는 노트 정보를 기반으로
- `noteNumber == 30`이면 🟩, 아니면 ⬜️로 표현
- 4개 단위로 띄어쓰기 추가 → 가독성 높임

---

### 🎧 `audioFiles` (Computed Property)

- `sampleFileNames` 배열을 기반으로 `AVAudioFile` 인스턴스 생성
- `Bundle.main`에서 오디오 샘플 파일을 로드하여 반환

---

## 🎼 전체 트랙 요약

| 트랙 | 용도      | 노트 번호 | 설명                        |
|------|-----------|-----------|-----------------------------|
| 0    | 베이스    | 24        | 시작(0), 중간(2)에 추가됨   |
| 1    | 서브베이스| 24        | 중간(2)에만 추가됨         |
| 2    | 하이햇     | 30        | 기본 8비트 패턴 or 랜덤 패턴 |
| 3    | 스네어     | 26        | 중간(2)에 추가됨           |

---

