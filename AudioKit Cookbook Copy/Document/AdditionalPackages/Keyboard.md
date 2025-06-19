# Keyboard

이 코드는 SwiftUI와 [AudioKit Keyboard](https://github.com/AudioKit/Keyboard), [Tonic](https://github.com/AudioKit/Tonic)를 활용한 **다양한 형태의 가상 키보드 데모 뷰**입니다.
사용자는 탭을 전환하며 여러 형태의 키보드를 체험할 수 있고, 실제로 MIDI note를 발생시켜 사운드를 출력할 수 있습니다.

---

## 📦 주요 구조

```swift
struct KeyboardView: View
```

### 🧠 역할 요약

* **여러 형태의 가상 키보드**를 탭(Tab) 기반 UI로 제공
* **키보드 레이아웃 및 터치 인터랙션**을 정의
* 사용자가 눌렀을 때 `InstrumentSFZConductor`가 해당 음을 재생

---

## 🧭 탭 구성 (TabView)

| 탭 이름   | 기능 설명                                              |
| ------ | -------------------------------------------------- |
| 세로 피아노 | `.verticalIsomorphic` / `.verticalPiano` 키보드 2종 비교 |
| 범위 조절  | 하단 키보드의 시작\~끝 음을 사용자가 조절 가능                        |
| 스케일    | 루트와 스케일에 따라 `.isomorphic` 키보드 변화                   |
| 기타     | 기타 스타일 키보드 + 커스텀 `.isomorphic` 키보드                 |

---

## 🎹 주요 키보드 레이아웃 종류

1. **`.verticalIsomorphic`**

   * 동일 간격으로 쌓이는 음표 배열
   * 이론적으로 한 방향은 루트, 다른 방향은 음정 간격 유지

2. **`.verticalPiano`**

   * 실제 피아노처럼 흰 건반/검은 건반을 위아래로 배열
   * 비율 조정은 `KeyboardSpacingInfo`에서 설정

3. **`.piano`**

   * 일반적인 수평 피아노 키보드

4. **`.isomorphic`**

   * 루트/스케일을 기준으로 격자형 배열을 생성 (색다른 시각적 피드백 가능)

5. **`.guitar`**

   * 기타처럼 줄과 프렛을 시각적으로 표현한 키보드

---

## 🎚 음정 범위 조절 (`범위 조절` 탭)

* `Stepper`를 통해 `lowNote`, `highNote`를 변경 가능
* 이 값에 따라 `.piano(...)` 키보드의 표시 범위가 변경됨

---

## 🧩 스케일 변경 (`스케일` 탭)

* `root`: 기준 음 (`NoteClass`)
* `scale`: 스케일 종류 (`Scale.allCases`)
* 사용자가 스케일이나 루트를 변경하면 `.isomorphic` 키보드에 반영됨
* `changeRoot(isIncrement:)` 함수로 루트 이동 (`C → C# → D ...`)

---

## 🎨 기타 탭 - 커스텀 키보드 UI

```swift
Keyboard(layout: .guitar(), noteOn: ..., noteOff: ...) { pitch, isActivated in
  KeyboardKey(...)
}
```

* 각 키마다 눌렸을 때 색상 및 텍스트를 커스터마이징
* `PitchColor.newtonian` 배열을 사용하여 음정에 따라 색상 구분

---

## 🎵 음 재생 처리

`InstrumentSFZConductor`는 `.noteOn`, `.noteOff`를 구현한 오디오 컨트롤러입니다.

### 추가로:

```swift
private extension InstrumentSFZConductor {
  func noteOnWithVerticalVelocity(pitch: Pitch, point: CGPoint) { ... }
}
```

* Y 좌표(수직 위치)에 따라 Velocity 값을 조절해, **터치 위치에 따른 강약 조절**도 가능하게 함

---

## 🧰 기타 구조

### `KeyboardSpacingInfo`

* `.verticalPiano`에 쓰이는 간격 정의 정보
* 흰 건반/검은 건반의 상대 위치와 폭을 수학적으로 정의함

### `VNodeOutputView`

* `AudioKitUI`에서 시각적으로 오디오 출력을 보여주는 뷰 (옵션)

---

## ✅ 전체 흐름 요약

1. `KeyboardView`는 다양한 종류의 키보드 UI를 `TabView`로 제공
2. 각 키보드는 `noteOn`, `noteOff` 클로저로 연결되어 실제 음을 재생
3. 사용자는 피아노, 기타, 이소모픽 스케일, 범위조절 등 다양한 상호작용을 할 수 있음
4. 배경색은 다크모드 여부에 따라 동적으로 변경됨

---

## 🧪 테스트하려면

```swift
#Preview {
  KeyboardView()
}
```

* SwiftUI 프리뷰에서 직접 인터랙션 테스트 가능

---

# PitchColor.newtonian

`PitchColor.newtonian`은 `AudioKit`의 `Tonic` 라이브러리에서 제공하는 **음 높이에 대응하는 색상 배열**입니다. 즉, \*\*각 음(pitch class)\*\*에 대해 특정 색을 할당하여 시각적으로 표현할 수 있게 하는 **컬러 팔레트** 중 하나입니다.

---

## 🎨 의미 요약

* **`PitchColor`**: 음(노트)에 색상을 대응시키기 위한 구조체 또는 열거형
* **`.newtonian`**: 그중 하나의 색상 배열 (총 12개 — 12 반음에 해당)

---

## 📦 실제 정의 예 (간략화 예시)

```swift
PitchColor.newtonian = [
  Color.red,       // C
  Color.orange,    // C#
  Color.yellow,    // D
  Color.green,     // D#
  Color.cyan,      // E
  Color.blue,      // F
  Color.indigo,    // F#
  Color.purple,    // G
  Color.pink,      // G#
  Color.gray,      // A
  Color.black,     // A#
  Color.white      // B
]
```

즉, `pitch.pitchClass`가 0\~11일 때:

```swift
Color(PitchColor.newtonian[Int(pitch.pitchClass)])
```

이 코드는 **C부터 B까지 각 음에 대해 정해진 색상**을 가져와 키보드 등에서 사용할 수 있게 합니다.

---

## 💡 "newtonian" 이름 유래?

* 이름은 아마도 아이작 뉴턴(Isaac Newton)이 주장했던 **음과 색의 대응 이론**에서 온 것으로 보입니다.
* 뉴턴은 7음계(CDEFGAB)와 무지개의 7색(R-O-Y-G-B-I-V)을 대응시킨 바 있습니다.

---

## ✅ 사용 예

```swift
let color = PitchColor.newtonian[pitch.pitchClass]
```

* `pitch.pitchClass`는 0(C), 1(C#), ..., 11(B) 중 하나
* 해당 색상은 키보드의 `pressedColor` 또는 시각적 강조에 사용

---

## 🎯 정리

| 요소           | 의미                    |
| ------------ | --------------------- |
| `PitchColor` | 음에 대응하는 색상 팔레트 모음     |
| `.newtonian` | C\~B 12음에 대한 고정 색상 배열 |
| 용도           | 키보드 시각화, 스케일 색상 강조 등  |

---

# Keyboard Spacing 관련 정보

이 코드는 [**AudioKit Keyboard**](https://github.com/AudioKit/Keyboard) 라이브러리와 [**AudioKit Tonic**](https://github.com/AudioKit/Tonic)를 사용하여, SwiftUI에서 \*\*세로형 피아노 키보드(Vertical Piano Layout)\*\*를 커스터마이즈한 예제입니다.

---

## 🎯 목적 요약

* `Keyboard(...)`를 통해 SwiftUI 내에 **가상 피아노 키보드 뷰**를 생성
* `.verticalPiano(...)` 레이아웃을 적용하여 **세로방향 키보드** 구성
* **음 이름(`Letter`)별 여백 비율과 흑건(검은 건반) 너비**를 직접 지정해서 피아노 키 간격을 커스터마이즈

---

## 📦 핵심 구성 요소

### 1. `evenSpacingInitialSpacerRatio`

```swift
let evenSpacingInitialSpacerRatio: [Letter: CGFloat] = [
  .C: 0.0,
  .D: 2.0 / 12.0,
  .E: 4.0 / 12.0,
  .F: 0.0 / 12.0,
  .G: 1.0 / 12.0,
  .A: 3.0 / 12.0,
  .B: 5.0 / 12.0
]
```

* 각 흰 건반(`Letter`) 앞에 **얼마나 여백을 둘지**를 비율로 나타냄
* 주로 **검은 건반과의 상대적인 위치 보정**에 사용됨
* 예: D는 앞에 2/12 만큼 띄워짐 → C# 위치 확보용

---

### 2. `evenSpacingSpacerRatio`

```swift
let evenSpacingSpacerRatio: [Letter: CGFloat] = [
  .C: 7.0 / 12.0,
  .D: 7.0 / 12.0,
  ...
]
```

* 각 흰 건반의 **자기 자신 이후에 생길 "스페이서" 길이 비율**
* 기본적으로 일정한 간격(`7/12`) 유지
* 실제로는 전체 키 간격 = 앞쪽 initialSpacer + 자기 폭 + 뒤쪽 spacer

---

### 3. `evenSpacingRelativeBlackKeyWidth`

```swift
let evenSpacingRelativeBlackKeyWidth: CGFloat = 7.0 / 12.0
```

* 검은 건반의 **상대 너비 비율**
* 1.0은 흰 건반과 동일한 폭, 0.58 정도가 일반적 현실 비율
* 여기선 꽤 넓은 검은 건반으로 설정됨

---

## 🎹 `Keyboard(layout: .verticalPiano(...))`

```swift
Keyboard(
  layout: .verticalPiano(
    pitchRange: Pitch(48)...Pitch(77),
    initialSpacerRatio: evenSpacingInitialSpacerRatio,
    spacerRatio: evenSpacingSpacerRatio,
    relativeBlackKeyWidth: evenSpacingRelativeBlackKeyWidth
  )
)
```

* `.verticalPiano(...)`: AudioKit Keyboard 라이브러리에서 제공하는 **세로방향 건반 레이아웃**
* `pitchRange`: C3 (MIDI 48) \~ F6 (MIDI 77) 범위의 키 표시
* `initialSpacerRatio`, `spacerRatio`: 키 간격 및 여백 설정
* `relativeBlackKeyWidth`: 검은 건반의 너비 조절

---

## 🔍 실제 결과

* 화면에 **C3\~F6 범위의 세로 피아노 키보드**가 표시됨
* 각 키는 지정된 간격대로 배치됨 (즉, 실제 피아노 비율이 아님 → `evenSpacing`)
* **디자인 시 균일 간격/비대칭 조정**에 유용

---

## ✅ 정리

| 항목                      | 설명                             |
| ----------------------- | ------------------------------ |
| `Keyboard(layout:)`     | AudioKit의 가상 키보드 SwiftUI 뷰     |
| `.verticalPiano(...)`   | 세로 방향 건반 배치                    |
| `initialSpacerRatio`    | 각 키 앞에 얼마나 띄울지 비율 설정           |
| `spacerRatio`           | 각 키 뒤에 얼마나 띄울지 비율 설정           |
| `relativeBlackKeyWidth` | 검은 건반의 상대적인 폭 (1.0 = 흰 건반과 동일) |
| `Pitch(48)...Pitch(77)` | MIDI 기준 C3\~F6 범위의 키 표시        |

---


