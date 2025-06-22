# MIDI Port Test (Virtual MIDI Host 포함)

---

# MIDIPortTestConductor

`MIDIPortTestConductor`는 AudioKit과 MIDIKit을 이용해 MIDI 포트를 테스트하거나 MIDI 이벤트를 수신/전송할 수 있도록 설계된 **MIDI 테스트 도구의 핵심 로직 클래스**입니다. 가상 포트를 생성하고, 외부 장치와 통신하며, MIDI 로그를 저장하고, 포트 정보를 조회하는 기능을 포함합니다.

---

## ✅ 주요 목적

* 가상 MIDI 입/출력 포트 생성 및 관리
* 외부 MIDI 장치 연결 및 포트 열기/닫기
* MIDI 이벤트 실시간 수신 및 로그 기록
* 특정 포트로 이벤트 전송
* 테스트용 UI와의 연결을 위한 ObservableObject 구현

---

## ✅ 주요 구성요소 설명

### 📌 고정 UID 정의

```swift
let inputUIDDevelop: Int32 = 1_200_000
let outputUIDDevelop: Int32 = 1_500_000
let inputUIDMain: Int32 = 2_200_000
let outputUIDMain: Int32 = 2_500_000
```

* 고정된 UID를 가진 가상 포트를 생성하기 위해 사용됨
* UID 기반으로 포트 교체(swap)하거나 구분 가능

---

### 📌 `@Published` 속성

```swift
@Published var log = [MIDIEvent]()
@Published var outputIsOpen: Bool
@Published var outputPortIsSwapped: Bool
@Published var inputPortIsSwapped: Bool
```

* UI에서 실시간으로 바뀌는 값을 추적할 수 있도록 상태 노출
* MIDI 이벤트 기록(log), 포트 스왑 여부, 출력 포트 오픈 여부 관리

---

### 📌 MIDI 초기화

```swift
midi.destroyAllVirtualPorts()
midi.createVirtualInputPorts(...)
midi.createVirtualOutputPorts(...)
midi.addListener(self)
```

* 기존 포트를 제거하고, UID를 지정한 가상 포트 생성
* `self`를 `MIDIListener`로 등록하여 수신 처리 가능

---

### 📌 로그 버퍼링 및 Timer 처리

```swift
private var logBuffer = [MIDIEvent]()
private var logTimer: Timer?
```

* MIDI 이벤트를 실시간으로 `logBuffer`에 임시 저장
* 0.5초마다 한 번씩 `flushLogBuffer()`를 호출해 log에 삽입 → UI 성능 저하 방지

---

### 📌 포트 설명 캐싱

```swift
private var portDescriptionCache: [MIDIUniqueID : PortDescription]
```

* `inputPortDescription(forUID:)` 함수에서 매번 조회하지 않고 캐싱
* 초기화 시 백그라운드 스레드에서 inputInfos를 순회해 캐싱해둠

---

### 📌 포트 열기 및 닫기

```swift
func didSetOutputIsOpen() { ... }
func openOutputs() { ... }
func start() / stop()
```

* `outputIsOpen`이 바뀔 때 포트를 열거나 닫음
* `start()`는 input 포트 열기, `stop()`은 모두 닫기

---

### 📌 이벤트 전송

```swift
func sendEvent(eventToSend:event, portIDs:[MIDIUniqueID]?)
```

* MIDIEvent 객체를 보고 적절한 AudioKit 전송 함수 호출

  * `.controllerChange` → `sendControllerMessage`
  * `.programChange` → `sendEvent(...)`
  * `.noteOn` / `.noteOff` → 각각 전송
* `swapVirtualOutputPorts()`로 포트 교체 가능

---

### 📌 포트 스왑 기능

```swift
func swapVirtualInputPort(...)
func swapVirtualOutputPorts(...)
```

* 개발용 포트와 메인 포트를 교체하여 라우팅 방식 변경 가능
* 예: 출력 포트 UID가 `outputUIDDevelop`이면 → `inputUIDDevelop`로 바꿈

---

### 📌 MIDIListener 구현

```swift
receivedMIDINoteOn(...)
receivedMIDIController(...)
...
```

* MIDIKit이 제공하는 이벤트 콜백
* 수신된 이벤트를 `logBuffer`에 추가
* 로그에 포트 ID 포함 → 어떤 포트에서 들어온 메시지인지 추적 가능

---

## ✅ 요약

| 기능          | 설명                                        |
| ----------- | ----------------------------------------- |
| 가상 포트 생성    | 고정 UID로 input/output 포트 생성                |
| 포트 상태 토글    | outputIsOpen으로 열고 닫음                      |
| 포트 스왑       | 개발용/메인 포트를 상황에 따라 교체                      |
| MIDI 이벤트 수신 | MIDIListener 프로토콜 구현                      |
| 이벤트 로그 기록   | `logBuffer` + 타이머 → `@Published log`      |
| 포트 정보 조회    | UID → 제조사/장치 이름 조회 및 캐싱                   |
| 이벤트 전송      | noteOn/noteOff/controller/program 등 구분 전송 |

---

# MIDIPortTestView

`MIDIPortTestView`는 AudioKit + MIDIKit 기반의 SwiftUI 뷰로,
**가상 및 외부 MIDI 포트의 입출력 테스트, CC/노트 전송, 포트 선택 및 실시간 로그 확인** 기능을 제공합니다.
앱 또는 MIDI 툴에서 **MIDI 포트 동작 상태를 시각적으로 테스트하거나 디버그하는 데 유용**한 구성입니다.

---

## ✅ 전체 구조 요약

```swift
MIDIPortTestView
 ├─ HeaderArea                     ← 포트 개수 및 이름 헤더 표시
 ├─ TabView                       ← 포트1/포트2 전환 UI
 │   ├─ Port1SelectArea           ← Destination 포트 선택
 │   ├─ Port2SelectArea           ← Virtual Output 포트 선택
 │   └─ PortEventArea(portID)     ← 선택 포트로 Note/CC 전송 버튼들
 ├─ 포트 스왑/출력 여부 Toggle
 ├─ LogResetButtonArea            ← 로그 초기화 버튼
 ├─ LogHeaderArea                 ← MIDI 로그의 컬럼 헤더
 └─ LogDataArea                   ← 수신된 MIDI 로그 목록 표시
```

---

## 🧩 주요 구성 요소 설명

### 📌 `HeaderArea`

```swift
HeaderCell(...) // 4칸
```

* 현재 MIDI 시스템에 등록된 포트 정보(입력/출력/가상 등)의 개수, 이름, UID를 표시

---

### 📌 `TabView` + `Port1/2SelectArea`

```swift
TabView { VStack { Port1SelectArea ... } }
```

* `PageTabViewStyle`로 구성
* 첫 페이지: 외부 Destination 포트 선택 + 버튼 전송
* 두 번째 페이지: Virtual Output 포트 선택 + 전송

---

### 📌 `PortEventArea(portID:)`

```swift
MIDIEventButton(eventToSend: .noteOn / .noteOff ...)
```

* 하드코딩된 노트 번호(\[60, 62, 64, 67, 69] 등)로 NoteOn/NoteOff 전송 버튼
* ProgramChange(랜덤 악기 변경), CC 1 (Mod Wheel) 전송 버튼 포함
* 버튼 클릭 시 `conductor.sendEvent(...)` 호출로 해당 포트에 MIDI 전송

---

### 📌 로그 관련 UI

#### ▸ `LogHeaderArea`

* 상태, 채널, 데이터1\~2, 포트 UID, 장치명, 제조사명 등 컬럼 헤더 출력

#### ▸ `LogDataArea`

```swift
ForEach(conductor.log.indices) { i in ... }
```

* 실시간 MIDI 이벤트 로그 출력
* 한 줄당 `.LazyHStack`으로 7개 항목 출력
* `conductor.inputPortDescription(forUID:)`를 통해 포트 UID → 이름/제조사 변환 (성능 저하 원인)

---

### 📌 포트 상태 전환 토글

```swift
Toggle(isOn: $conductor.outputIsOpen) { ... }
Toggle(isOn: $conductor.inputPortIsSwapped) { ... }
Toggle(isOn: $conductor.outputPortIsSwapped) { ... }
```

* `outputIsOpen`: `openOutputs()` 실행 여부
* `inputPortIsSwapped`: 가상 입력 포트 UID 스왑 여부
* `outputPortIsSwapped`: 가상 출력 포트 UID 스왑 여부
  → `conductor.swapVirtualInputPort(...)` 등의 포트 경로 제어에 영향

---

## 🎛️ 기능 요약

| 기능          | 설명                               |
| ----------- | -------------------------------- |
| 포트 선택       | 외부 포트 및 가상 포트 드롭다운 선택            |
| MIDI 이벤트 전송 | NoteOn/Off, CC, ProgramChange 전송 |
| 포트 스왑       | 가상 포트 UID를 상황에 따라 교체             |
| 로그 보기       | 수신된 MIDI 이벤트 로그 실시간 표시           |
| 로그 초기화      | 버튼으로 로그 지우기                      |

---

## ⚠️ 주의/개선 포인트

* `LogDataArea`에서 `inputPortDescription()`은 성능 병목 → 캐싱 또는 비동기 평가 필요
* 포트 수가 많을 경우 Picker나 log 처리 성능 저하 발생 가능
* 각 포트별 상태나 활성화 여부도 추가 UI로 제공 가능

---

## ✅ 요약

`MIDIPortTestView`는:

* **가상/외부 MIDI 포트를 선택하고**
* **테스트용 MIDI 이벤트를 보내며**
* **수신되는 MIDI 로그를 실시간으로 시각화**하는 데 최적화된 SwiftUI 뷰입니다.

테스트 도구, 디버깅 뷰, 또는 DAW 플러그인 개발자용 MIDI 유틸리티로 활용할 수 있습니다.

---
