# Flow

이 코드는 SwiftUI와 [**Flow**](https://github.com/audiokit/Flow) 라이브러리를 이용해 **모듈형 오디오 또는 비주얼 그래프 편집기** 인터페이스를 구현한 예제입니다. 사용자는 "Simple" 또는 "Random" 패치 구성을 선택하여 그래프 형태로 노드(Node)와 와이어(Wire)를 시각적으로 다룰 수 있습니다.

---

## 🧠 핵심 클래스: `FlowConductor`

`ObservableObject`를 채택한 뷰 모델로서, `FlowView`에서 사용됩니다.

### 🔸 주요 프로퍼티

* `patch: Patch`: 현재 그래프 구조 (노드 + 와이어 집합)
* `selection: Set<NodeIndex>`: 사용자가 현재 선택한 노드들
* `segIndex: Int`: "Simple" 또는 "Random" 구성을 고르는 Segment Picker의 선택 인덱스

### 🔸 `init()`

* 뷰가 처음 생성될 때 `simplePatch()`를 호출해 기본 구성의 패치를 설정

---

## 🔧 `simplePatch()` 함수

간단한 오디오/비주얼 흐름 예제를 구성합니다:

1. **노드 생성**

   * `generator`, `processor`, `mixer`, `output` 총 6개 노드를 생성
   * `generator`와 `processor` 각각 두 개씩 → 총 6개 노드
   * 각 노드는 이름, 입력/출력 포트, 색상 정보를 가짐

2. **와이어 연결**

   * `Wire(from: OutputID, to: InputID)` 형태로 노드 간 연결
   * 각 와이어는 **출력 포트 → 입력 포트**를 의미

   예:

   ```swift
   Wire(from: OutputID(0, 0), to: InputID(1, 0))
   ```

   → 첫 번째 generator(노드 0)의 출력이 첫 번째 processor(노드 1)의 입력으로 연결됨

3. **배치 레이아웃 설정**

   * 마지막 노드(출력 노드, 인덱스 5)를 기준 위치 `(800, 50)`에 고정
   * `recursiveLayout`을 통해 나머지 노드들이 자동 배치됨

4. \*\*`self.patch = patch`\*\*로 최종 구성 반영

---

## 🔀 `randomPatch()` 함수

* 무작위 노드 50개와 와이어 50개를 생성하여 **복잡한 그래프 구성 예제**를 제공
* 각 노드는 랜덤한 위치 및 색상
* 각 와이어는 랜덤하게 다른 노드와 연결됨

이 함수는 `segIndex`가 1일 때 실행됩니다.

---

## 🖼️ `FlowView`: SwiftUI View

### 구조:

```swift
VStack {
  Picker(...)        // "Simple" 또는 "Random" 선택
  NodeEditor(...)    // Flow 라이브러리의 메인 편집기 뷰
}
```

* `.onAppear`: 화면이 나타날 때 가로모드 강제 전환
* `.onDisappear`: 뷰가 사라질 때 방향 제한 해제

### `Picker("Select the Patch", selection: $conductor.segIndex)`

* 사용자가 선택한 값(`segIndex`)에 따라 `simplePatch()` 또는 `randomPatch()`가 자동 호출됨

---

## 🧭 `NodeEditor(...)`

* Flow 라이브러리의 메인 UI로, 노드와 와이어를 시각적으로 편집할 수 있게 하는 컴포넌트
* `$conductor.patch`, `$conductor.selection`과 바인딩되어 실시간 편집 가능

---

## 🧪 기타

* `#Preview`: SwiftUI Preview용 코드
* `forceOrientation(...)`: 가로모드로 화면 강제 전환 (별도 구현되어야 함)

---

## ✅ 요약

| 구성 요소           | 역할                            |
| --------------- | ----------------------------- |
| `FlowConductor` | 노드 및 연결 정보를 관리하는 뷰 모델         |
| `simplePatch()` | 미리 정의된 간단한 노드 구성 설정           |
| `randomPatch()` | 50개의 랜덤 노드 및 연결 구성            |
| `NodeEditor`    | 노드 기반 UI를 표시하고 편집 가능하게 하는 뷰   |
| `segIndex`      | SegmentPicker로 사용자가 선택한 구성 판단 |
| `.onAppear`     | 뷰 진입 시 가로모드 강제                |

---

## Simple Patch 동작 해석

`Flow` 라이브러리에서 `Wire`는 **두 노드를 연결하는 선**을 의미합니다. 실제로는 **한 노드의 출력 포트(OutputID)가 다른 노드의 입력 포트(InputID)로 연결**되는 구조입니다.

```swift
let wires = Set([
  Wire(from: OutputID(0, 0), to: InputID(1, 0)), // gen 1 -> proc 1
  Wire(from: OutputID(1, 0), to: InputID(4, 0)), // proc 1 -> mixer
  Wire(from: OutputID(2, 0), to: InputID(3, 0)), // gen 2 -> proc 2
  Wire(from: OutputID(3, 0), to: InputID(4, 1)), // proc 2 -> mixer
  Wire(from: OutputID(4, 0), to: InputID(5, 0)), // mixer -> output
])
```

이제 이걸 기반으로 **Wire 간의 동작 흐름을 실제 예제로 해석**해보겠습니다.

---

## 🎯 노드 구성 요약 (nodes 배열 순서)

| 인덱스 | 노드 이름     | 타입      | 입력       | 출력  |
| --- | --------- | ------- | -------- | --- |
| 0   | generator | source  | 없음       | out |
| 1   | processor | effect  | in       | out |
| 2   | generator | source  | 없음       | out |
| 3   | processor | effect  | in       | out |
| 4   | mixer     | utility | in1, in2 | out |
| 5   | output    | sink    | in       | 없음  |

---

## 🔗 Wire 흐름 예제 해석

### 1. `Wire(from: OutputID(0, 0), to: InputID(1, 0))`

* **generator 1** → **processor 1**
* generator 1의 첫 번째 출력(`"out"`) → processor 1의 첫 번째 입력(`"in"`)
* ▶️ 첫 번째 오디오 소스가 이펙터로 들어감

---

### 2. `Wire(from: OutputID(1, 0), to: InputID(4, 0))`

* **processor 1** → **mixer (in1)**
* processor 1 출력 → mixer의 첫 번째 입력(`"in1"`)
* ▶️ 이펙트 처리된 소리가 믹서로 들어감

---

### 3. `Wire(from: OutputID(2, 0), to: InputID(3, 0))`

* **generator 2** → **processor 2**
* 두 번째 소스 → 두 번째 이펙터

---

### 4. `Wire(from: OutputID(3, 0), to: InputID(4, 1))`

* **processor 2** → **mixer (in2)**
* ▶️ 이펙트 처리된 두 번째 소리가 믹서로 들어감

---

### 5. `Wire(from: OutputID(4, 0), to: InputID(5, 0))`

* **mixer** → **output**
* 믹서의 결과가 최종 출력 노드로 이동

---

## 📊 시각적 흐름 요약 (왼쪽 → 오른쪽)

```
gen1 → proc1 ┐
             ├→ mixer → output
gen2 → proc2 ┘
```

* 두 개의 소스 → 각자 이펙트 처리 → 믹서로 병합 → 최종 출력
* 이 구조는 **이중 채널 처리**, **병렬 이펙팅 후 믹싱** 등의 오디오 워크플로우와 유사합니다

---

## 🧩 실제 활용 시 예시 (AudioKit 연결 예)

| 노드        | 연결 대상 (AudioKit)             |
| --------- | ---------------------------- |
| generator | `Oscillator()` 또는 `Player()` |
| processor | `LowPassFilter`, `Reverb` 등  |
| mixer     | `Mixer()`                    |
| output    | `engine.output = ...`        |

---

## ✅ 정리

| Wire 구성                    | 의미                  |
| -------------------------- | ------------------- |
| `OutputID(a, x)`           | a번 노드의 x번째 출력 포트    |
| `InputID(b, y)`            | b번 노드의 y번째 입력 포트    |
| `Wire(from: ..., to: ...)` | a번 노드 → b번 노드 간 연결선 |

이 구조는 실제 오디오 시그널 플로우(신호 흐름)를 시각화하거나, 실시간 처리 체인을 구성할 때 매우 직관적입니다.

---



