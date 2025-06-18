# Playlist

이 코드는 AudioKit과 SwiftUI를 사용해 만든 **간단한 오디오 플레이리스트 앱**입니다.
사용자가 폴더를 선택하면 그 안에 있는 오디오 파일 목록이 표시되고, 클릭 시 선택한 파일을 재생하거나 중지할 수 있습니다.

---

## 🧠 주요 클래스: `PlaylistConductor`

### ▶ 역할

* 오디오 재생 관리 (`AudioEngine`, `AudioPlayer`)
* 폴더에서 오디오 파일 불러오기
* 현재 재생 중인 파일 상태 추적

---

### 📌 내부 구조 설명

```swift
struct AudioFile: Identifiable, Hashable
```

* 개별 오디오 파일을 표현
* `id`는 고유 식별자
* `url`: 파일 경로
* `name`: 파일 이름 (확장자 없이)

---

```swift
let player = AudioPlayer()
```

* AudioKit의 단순 재생기
* `.play()`, `.stop()`, `.load(url:)`로 파일 제어

---

```swift
@Published var loadedFile: AudioFile?
```

* 현재 재생 중인 파일
* SwiftUI에서 상태 변화 감지를 위해 사용

---

### 🎧 `togglePlayback(of:)`

* 파일이 재생 중이면 중지하고 `loadedFile = nil`
* 다른 파일이 선택되면 현재 재생 중지 후 새 파일 재생
* 아무 것도 안 재생 중이면 바로 재생

---

### 🎼 `loadStartPlayback(of:)`

* `AVAudioFile`을 로드하고 재생 시작
* `loadedFile`에 현재 재생 중 파일 저장

---

### 📂 `getAudioFiles(in:)`

* 주어진 폴더 경로에서 지원하는 오디오 파일 확장자만 필터링하여 리스트 생성

---

### ✅ `playbackCompletionHandler`

* 현재 파일이 끝나면 `loadedFile = nil` → UI에서 상태 변경 반영 가능

---

## 🖼️ 뷰 구조: `PlaylistView`

### ▶ 주요 기능

* 폴더 열기 버튼
* 재생 상태에 따라 **파형 표시** 또는 설명 텍스트 표시
* 오디오 파일 리스트 렌더링 및 버튼 클릭 처리

---

### 💡 주요 UI 요소

#### `ZStack { if isPlaying ... }`

* 재생 중이면 `NodeRollingView`로 파형 표시
* 아니면 안내 문구 표시
* `.transition(.opacity)` + `.animation(...)`으로 자연스럽게 페이드 전환

---

#### `Button("Select Playlist Folder")`

* 폴더 선택을 트리거
* `.fileImporter`에서 폴더 선택 → 보안 권한 확보 후 파일 목록 읽기

---

#### `List { ForEach(conductor.audioFiles ...) }`

* 오디오 파일 이름 목록
* 클릭 시 `togglePlayback()` 호출
* 현재 재생 중인 항목에는 `"play.fill"` 아이콘 표시

---

## ✅ 전체 앱 흐름 요약

1. 앱 실행 후 \[Select Playlist Folder] 버튼 클릭
2. 폴더 선택 → 오디오 파일 목록 생성
3. 리스트에서 오디오 파일 클릭 → 재생
4. 같은 파일 재클릭 → 정지
5. 다른 파일 클릭 → 현재 정지 후 새 파일 재생
6. 파일 재생 완료 시 자동으로 정지 상태로 전환

---

## 🧩 사용 기술 요약

| 기술                     | 설명                  |
| ---------------------- | ------------------- |
| `AudioKit`             | 오디오 재생 기능 구현        |
| `AudioPlayer`          | 단일 오디오 파일 재생        |
| `SwiftUI`              | UI 구성 및 상태 관리       |
| `@Published`           | 상태 변경 UI 반영         |
| `transition(.opacity)` | 재생 상태 변화에 따른 페이드 효과 |
| `fileImporter`         | 보안 폴더 접근 UI 지원      |

---

필요하시면 다음도 설명드릴 수 있습니다:

* `NodeRollingView`가 실제로 어떤 시각화를 렌더링하는지
* 재생 중 자동으로 스크롤되는 리스트 구현 방법
* 여러 파일을 큐처럼 연속 재생하는 기능 추가 방법

