# Input Device Demo

이 SwiftUI + AudioKit 코드의 목적은 **입력 장치(마이크)를 선택하고 오디오 입력을 시작/정지하는 UI를 제공하는 것**입니다.
즉, 여러 마이크 장치가 연결된 환경에서 사용자가 원하는 입력을 선택하고, 마이크 버튼을 눌러 오디오 입력을 켜거나 끌 수 있게 합니다.

> Channel/Device Routing 예제와 거의 동일

---

## 🔧 클래스: `InputDeviceDemoConductor`

### ✅ 역할: 오디오 입력 장치 관리 + AudioKit 엔진 제어

#### 주요 속성

| 변수                | 설명                                        |
| ----------------- | ----------------------------------------- |
| `engine`          | AudioKit의 `AudioEngine` 인스턴스              |
| `mic`             | 현재 연결된 오디오 입력 노드 (`engine.input`)         |
| `mixer`           | 입력을 오디오 엔진의 출력으로 연결하기 위한 믹서 노드            |
| `inputDevices`    | `AVAudioSession`에서 얻은 사용 가능한 오디오 입력 장치 목록 |
| `inputDeviceList` | `Picker`에 표시할 장치 이름 목록 (portName 배열)      |

#### `init()`

* 오디오 입력 노드가 있을 경우 `mic`에 할당하고 `Mixer(input)`으로 연결
* 입력 장치 목록(`inputDevices`)을 불러와 `portName`을 `inputDeviceList`에 저장
* `engine.output = mixer`를 통해 믹서를 엔진의 출력으로 설정

#### `switchInput(number:)`

* 선택된 입력 장치를 `setPreferredInput(...)`으로 변경
* 변경 전에는 `stop()` 호출로 엔진을 멈춤

---

## 🖼️ View: `InputDeviceDemoView`

### ✅ 역할: UI를 통해 입력 장치 선택 및 오디오 입력 시작/정지

#### 주요 상태 변수

| 변수            | 설명                                 |
| ------------- | ---------------------------------- |
| `isPlaying`   | 오디오 입력이 현재 켜져 있는지 여부               |
| `inputDevice` | 현재 선택된 입력 장치의 인덱스 (`Picker`에서 선택됨) |

---

### ✅ 뷰 구조 설명

#### 📍 안내 텍스트

```swift
Text("Please plug in headphones")
Text("to avoid a feedback loop.")
Text("Then, select a device to start!")
```

* 피드백(하울링)을 피하기 위해 이어폰 사용을 권장

---

#### 🎛 입력 장치 선택 Picker

```swift
Picker("Input Device", selection: $inputDevice) {
  ForEach(conductor.inputDeviceList.indices, id: \.self) { i in
    Text(conductor.inputDeviceList[i])
      .tag(i)
  }
}
```

* `conductor.inputDeviceList`에 저장된 장치 이름을 기반으로 Picker 구성
* 선택이 변경되면 `.onChange(of: inputDevice)`를 통해 `switchInput(...)` 호출

---

#### 🎤 마이크 on/off 버튼

```swift
Button {
  isPlaying ? conductor.stop() : conductor.start()
  isPlaying.toggle()
}
```

* 클릭 시 마이크 입력이 시작되거나 종료
* 버튼의 아이콘은 `isPlaying` 상태에 따라 `"mic.circle"` 또는 `"mic.circle.fill"`로 바뀜
* `.resizable()` + `.frame(...)`으로 크기와 정렬 지정

---

#### 📤 종료 시 동작

```swift
.onDisappear {
  conductor.stop()
}
```

* 뷰가 사라질 때 자동으로 오디오 입력 종료

---

## ✅ 전체 동작 요약

| 상황    | 동작                                   |
| ----- | ------------------------------------ |
| 앱 시작  | AudioKit 엔진 초기화 + 사용 가능한 입력 장치 목록 확보 |
| 장치 선택 | 선택된 장치로 입력 전환 (`switchInput`)        |
| 버튼 클릭 | 오디오 입력 시작/정지 (`start()` / `stop()`)  |
| 뷰 종료  | 입력 강제 종료                             |

---

## ✅ 확장 가능성

* 입력 장치별 채널 수 확인
* 입력을 파일로 녹음
* 출력 장치 설정도 추가 가능

---

이 코드는 AudioKit을 활용한 **기초 오디오 입출력 제어 구조**를 익히기에 적절한 예제입니다. 
