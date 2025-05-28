# Drums

이 코드는 **AudioKit**을 활용한 **드럼 패드 앱의 핵심 구조**를 보여주는 예제입니다. 사용자가 UI 상에서 패드를 누르면 대응되는 드럼 사운드가 재생됩니다. 코드 전체는 다음 3가지 주요 구성 요소로 나뉩니다:

---

## 1. `DrumSample` – **드럼 사운드 데이터 모델**

```swift
struct DrumSample {
  var name: String        // 화면에 표시될 이름
  var fileName: String    // 번들 내 오디오 파일 이름
  var midiNote: Int       // MIDI 노트 번호
  var audioFile: AVAudioFile?
  var color: UIColor = .red
}
```

- 각 드럼 패드의 정보를 담는 구조체입니다.
- 초기화 시 번들에서 오디오 파일을 불러와 `AVAudioFile`로 저장합니다.
- 색상(`color`) 속성도 포함되어 있어 시각적 효과에 활용됩니다.

---

## 2. `DrumsConductor` – **오디오 처리 및 패드 재생 로직 (ViewModel 역할)**

```swift
class DrumsConductor: HasAudioEngine
```

- AudioKit의 `AppleSampler`를 사용하여 8개의 드럼 샘플을 로드하고 재생합니다.
- `playPad(padNumber:)` 함수는 해당 패드의 MIDI 노트를 통해 소리를 재생합니다.
- `@Observable`을 통해 SwiftUI에서 상태 관찰이 가능합니다.
- 초기화 시 샘플 오디오들을 `drums.loadAudioFiles(...)`로 등록합니다.

---

## 3. SwiftUI 뷰: `DrumsView`, `PadsView`

### ▶ `DrumsView`
```swift
struct DrumsView: View
```
- 상위 뷰이며 `PadsView`를 렌더링합니다.
- `.onAppear` / `.onDisappear`를 통해 AudioKit 엔진을 시작/정지합니다.

---

### ▶ `PadsView`
```swift
struct PadsView: View
```

#### 주요 기능:

- 2x4 드럼 패드 UI를 구성
- 각 패드는 `Rectangle` 뷰로 시각화
- 패드 ID는 `row * 4 + column` 계산식을 사용해 1차원 배열처럼 관리
- 드래그 제스처로 패드를 눌렀을 때:
  - `padId`가 `downPads`에 없다면 → `padsAction(padId)` 실행 + `downPads`에 추가
  - 손을 뗄 때(`.onEnded`) → 해당 `padId`를 `downPads`에서 제거

#### 제스처 처리:

```swift
.onChanged {
  if padId not in downPads {
    padsAction(padId)
    downPads.append(padId)
  }
}
.onEnded {
  downPads.remove(padId)
}
```

이 구조를 통해 **UI 반응성과 상태 변경 처리**가 동시에 이루어집니다.

---

## 🎨 시각적 상태 처리

### `padColor(padId:)` 함수

- `downPads`에 포함된 padId라면 `.gray`로 색상 처리
- 아니면 해당 드럼 샘플에 정의된 색상(`sample.color`) 사용

---

## 🧠 정리

| 구성 요소       | 역할 |
|----------------|------|
| `DrumSample`   | 드럼 하나의 데이터 구조 (이름, 파일명, 색상 등) |
| `DrumsConductor` | 오디오 엔진 및 샘플 로드, 패드 재생 제어 |
| `DrumsView`    | 상위 SwiftUI 뷰, 오디오 엔진 생명주기 제어 |
| `PadsView`     | 패드 레이아웃, 제스처 입력 처리, 상태 UI 반영 |

---

