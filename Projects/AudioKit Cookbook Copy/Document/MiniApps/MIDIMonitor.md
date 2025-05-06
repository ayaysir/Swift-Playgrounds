
# MIDI Monitor

이 `MIDIMonitor.swift` 파일은 SwiftUI 기반의 MIDI 모니터 도구입니다. MIDI 장치로부터 수신된 이벤트들을 실시간으로 감지하고 UI로 표시하는 역할을 합니다. **AudioKit**, **SwiftUI**, **CoreMIDI**를 활용하며, 사용자가 MIDI 장치의 입력을 확인하고 디버깅할 수 있도록 돕습니다.

---

## 🔧 주요 구조 설명

### 1. `MIDIMonitorData` 구조체

```swift
struct MIDIMonitorData {
  var noteOn, velocity, noteOff, channel, afterTouch, afterTouchNoteNumber, programChange, pitchWheelValue, controllerNumber, controllerValue: Int
}
```

* 각종 MIDI 이벤트 값을 저장하는 데이터 구조입니다.
* `@Published`로 선언되어 `View`에서 실시간 바인딩됩니다.

---

### 2. `MIDIMonitorConductor` 클래스

`ObservableObject`를 채택한 ViewModel 역할의 클래스입니다.

#### 주요 프로퍼티

* `midi`: AudioKit의 MIDI 인터페이스 객체
* `data`: MIDI 이벤트 데이터
* `isShowingMIDIReceived`: MIDI 입력을 수신 중일 때 indicator 표시 여부
* `isToggleOn`: CC 값이 127일 때 on 상태 (ex. 토글 스위치 UI용)
* `midiEventType`: 이벤트 구분용 열거형

#### 주요 메서드

* `start()`: MIDI 입력 포트 열고 리스너 등록
* `stop()`: MIDI 포트 닫기

---

### 3. MIDI 이벤트 수신 핸들러 (`MIDIListener` 구현)

AudioKit의 `MIDIListener` 프로토콜을 구현하여 다음 이벤트들을 처리합니다:

#### 📌 `receivedMIDINoteOn` / `receivedMIDINoteOff`

* 노트 번호, 벨로시티, 채널을 추출해 데이터 갱신
* 벨로시티가 0일 경우 `Note Off`처럼 취급하여 `isShowingMIDIReceived = false`

#### 📌 `receivedMIDIController`

```swift
if value == 127 {
  self.isToggleOn = true
} else {
  self.isToggleOn = false
}
```

* CC 메시지 수신 시 컨트롤러 번호와 값 저장
* `value == 127`이면 `isToggleOn`을 켜서 UI에 표시 (ex. 이펙터 스위치처럼 on/off 토글용)

#### 📌 기타 이벤트

* `Program Change`, `Pitch Wheel`, `Aftertouch` 등도 모두 개별적으로 처리하여 데이터를 반영

---

### 4. `MIDIMonitorView` 뷰

* `MIDIMonitorConductor`를 `@StateObject`로 사용
* 수신된 MIDI 이벤트를 `List`의 `Section`으로 구분하여 표시
* 상단에 MIDI 입력 상태와 토글 여부를 나타내는 **원형 인디케이터(Circle)** 표시

#### 인디케이터 예:

```swift
Circle()
  .fill(conductor.isShowingMIDIReceived ? mainTintColor : mainTintColor.opacity(0.2))
```

---

## 🧪 특징 및 활용 예시

* **드럼패드**를 누르면 Note On 이벤트 → 인디케이터 반응
* **노브를 돌리면** CC 메시지 → 컨트롤러 번호와 값 갱신
* **이펙터 on/off처럼** CC 값이 127 → `isToggleOn = true`로 빨간 불 표시

---
