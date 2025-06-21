# Tables

이 코드는 `AudioKit`의 `Table` 객체들을 생성하고 시각화하는 SwiftUI 뷰입니다.
특히 생성자(`init()`)에서는 다양한 방식으로 \*\*파형 테이블(Table)\*\*을 생성하여 오실레이터 등에서 사용할 수 있도록 준비합니다.
이 Table들은 사인파, 정사각파, 사용자 정의 파형 등의 **루프 가능한 단일 사이클 웨이브폼**입니다.

---

## ✅ 클래스 개요: `TableConductor`

이 클래스는 `ObservableObject`로, UI에서 이 객체의 `@Published` 값을 관찰할 수 있도록 구성되어 있습니다.

```swift
class TableConductor: ObservableObject
```

### 📌 속성 목록

| 속성 이름          | 역할                         |
| -------------- | -------------------------- |
| `square`       | 정사각형 파형 테이블 (Square Wave)  |
| `triangle`     | 삼각형 파형 테이블 (Triangle Wave) |
| `sine`         | 사인파 테이블 (Sine Wave)        |
| `sineHarmonic` | 하모닉(배음) 기반의 사인파            |
| `fileTable`    | 오디오 파일 기반 파형               |
| `custom`       | 사용자 정의 파형 (난수 + 인덱스 기반)    |

---

## 🧠 생성자 설명: `init()`

### 🔹 1. 기본 파형 테이블 생성

```swift
square = .init(.square, count: 128)
triangle = .init(.triangle, count: 128)
sine = .init(.sine, count: 256)
```

* `.init(_:count:)`는 해당 파형 유형의 테이블을 지정된 크기만큼 생성
* `count`는 **테이블 길이 (샘플 수)**, 2의 제곱수로 설정하는 것이 일반적 (FFT 등 성능에 영향)

---

### 🔹 2. 오디오 파일 기반 파형 생성

```swift
let url = GlobalSource.piano.url!
let file = try! AVAudioFile(forReading: url)
fileTable = .init(file: file)!
```

* `.sfz` 또는 `.wav` 등의 오디오 파일을 읽어 들여 파형 테이블로 변환
* `fileTable`은 실제 음성 데이터를 기반으로 한 루프 테이블이 됨
  
주의:
* 파일 로딩은 오래 걸릴 수 있으므로 생성자에서 직접 하지 말고 `task` 등을 통해 비동기적으로 실행

---

### 🔹 3. 하모닉 오버톤 기반 테이블 생성

```swift
let harmonicOvertoneAmplitudes: [Float] = [
  0.0, 0.0, 0.016, 0.301
]
sineHarmonic = .init(.harmonic(harmonicOvertoneAmplitudes), phase: 0.75)
```

* `AudioKit.TableType.harmonic(_)`은 \*\*기본파 + 배음(amplitudes)\*\*으로 구성된 파형 생성
* `harmonicOvertoneAmplitudes[n]`은 **(n+1)번째 고조파의 세기**
* `phase: 0.75`는 **위상 오프셋**으로, 시작 지점을 오른쪽으로 75%만큼 이동

예:
배음 = `[0.0, 0.0, 0.016, 0.301]`
→ 기본파 없음, 3번째와 4번째 고조파만 있는 파형

---

### 🔹 4. 사용자 정의 파형 생성

```swift
custom = Table(.sine, count: 256)
for i in custom.indices {
  custom[i] += Float.random(in: -0.5...0.5) + Float(i) / 2048.0
}
```

* 먼저 사인파 테이블을 생성한 뒤, 각 샘플에 **무작위 값 + 인덱스 기반 값**을 더함
* 이는 **잡음 성분이 섞인 사인파 또는 변형된 파형**을 만들기 위한 목적

예:

* `Float.random(in: -0.5...0.5)` → 랜덤 노이즈
* `Float(i) / 2048.0` → 위치에 따라 증가하는 값


---

## 🖼️ 테이블 시각화 뷰 (`TableDataView`)

```swift
struct TableDataView: UIViewRepresentable
```

* AudioKit에서 제공하는 `TableView`를 UIKit 기반으로 감싸 SwiftUI에서 사용 가능하게 함
* `table`을 주입받아 `makeUIView`에서 그려줌

---

## 📱 SwiftUI 구성 (`TableRecipeView`)

```swift
VStack {
  Text("Square")
  TableDataView(table: conductor.square)
  ...
}
```

* 각 Table을 `Text`와 함께 나열하여 시각적으로 비교 가능

---

## ✅ 요약

| 생성 방식                      | 설명              |
| -------------------------- | --------------- |
| `.init(.sine, count: N)`   | 기본형 파형 생성       |
| `.init(file:)`             | 오디오 파일 기반 파형    |
| `.init(.harmonic, phase:)` | 배음 기반 사용자 정의 파형 |
| `.init` + 인덱스 수식           | 완전 커스텀 파형       |

---

