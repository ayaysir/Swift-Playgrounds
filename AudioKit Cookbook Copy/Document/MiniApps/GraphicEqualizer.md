# Graphic Equalizer

---

## ✅ 전체 구조 요약

이 코드는 **SwiftUI + AudioKit** 기반의 **6밴드 그래픽 이퀄라이저** 구현입니다.
사용자가 각 주파수 대역의 Gain을 조정하면, 해당 대역의 오디오 출력에 실시간으로 반영됩니다.

---

## 1. `GraphicEqualizerData`

```swift
struct GraphicEqualizerData {
  private var gains: [AUValue] = Array(repeating: 1.0, count: 6)
  
  subscript(_ index: Int) -> AUValue {
    get {
      1...6 ~= index ? gains[index - 1] : 0
    }
    set {
      1...6 ~= index ? gains[index - 1] = newValue : nil
    }
  }
}
```

* `gains[0]`부터 `gains[5]`까지 6개 EQ 밴드의 Gain을 저장
* 외부에서는 `data[1] ~ data[6]`으로 접근할 수 있도록 `subscript` 정의
* UI 바인딩 및 필터 Gain 반영에 사용됨

---

## 2. `GraphicEqualizerConductor` – **음향 처리 흐름 설명**

### 🔊 오디오 구성 요소

```swift
let engine = AudioEngine()
let player = AudioPlayer()
let fader: Fader
var filterBands: [EqualizerFilter] = []
```

* `player`: 미리 정의된 오디오 버퍼(`Cookbook.sourceBuffer`)를 재생
* `EqualizerFilter`: 오디오 필터 체인을 구성 (6개 밴드)
* `fader`: 전체 볼륨 조절
* `engine.output = fader`: 전체 오디오 출력은 fader를 거쳐 출력됨

---

### 🧠 필터 체인 구성

```swift
let centerFrequencies: [AUValue] = [32, 64, 125, 250, 500, 1_000]
let bandwidths: [AUValue] = [44.7, 70.8, 141, 282, 562, 1_112]
```
* 각 필터는 센터 주파수와 대역폭을 기반으로 설정됩니다.
* `centerFrequencies`는 각 밴드의 주파수를 정의하며, `bandwidths`는 필터의 대역폭을 설정합니다. 
  * 대역폭이 넓으면 필터의 효과가 넓은 범위에 걸쳐 적용되며, 좁으면 그 범위가 좁아집니다.

#### 🎧 필터밴드 연결 과정

```swift
filterBands.append(EqualizerFilter(player)) // dummy index 0

for i in 1...6 {
  filterBands.append(
    EqualizerFilter(
      i == 1 ? player : filterBands[i - 1],
      centerFrequency: centerFrequencies[i - 1],
      bandwidth: bandwidths[i - 1],
      gain: 1.0
    )
  )
}
```

* **EqualizerFilter**는 대역 통과 필터입니다.
  각 필터는 특정 중심 주파수(`centerFrequency`)와 대역폭(`bandwidth`)에 대해 설정됩니다.
* **Signal Chain**:

  * `player → band1 → band2 → ... → band6 → fader → engine.output`
  * 순차적으로 필터들이 연결되며, 각 밴드의 gain을 조절해 해당 주파수 대역을 증폭 또는 감쇠합니다.

> 🎵 예: Band 1은 32Hz 중심의 저주파 필터이며, Band 6은 1kHz 중심의 중고역대 필터입니다.

---

### 🎚 실시간 Gain 반영

```swift
@Published var data = GraphicEqualizerData() {
  didSet {
    for i in 1...6 {
      filterBands[i].gain = data[i]
    }
  }
}
```

* SwiftUI에서 사용자가 Knob을 통해 gain을 조절하면 `data[i]` 값이 바뀌고, `filterBands[i].gain`이 즉시 반영되어 실시간 EQ 처리가 됩니다.

---

### 🔈 Fader 및 출력

```swift
fader = Fader(filterBands[6], gain: 0.4)
engine.output = fader
```

* 마지막 필터의 출력을 fader로 감싸 전체 볼륨 조절
* 이로써 전체 EQ 적용 후 출력이 엔진의 최종 출력이 됩니다

---

## 3. `GraphicEqualizerView`

```swift
ForEach(1...6, id: \.self) { index in
  CookbookKnob(text: "Band \(index)", parameter: $conductor.data[index], range: 0...20)
}
```

* SwiftUI의 노브 컴포넌트를 통해 사용자가 6개 밴드의 Gain을 조절 가능
* `@StateObject`로 `conductor`를 관리하여 실시간 반영
* 하단에는 `FFTView`를 통해 실시간 주파수 응답을 시각화함

---

## 음향적 측면에서의 동작

이 코드는 6개의 주파수 대역에 대해 각각 독립적인 **gain** 값을 설정하여, 입력된 오디오 신호를 주파수 대역별로 필터링하고 조절할 수 있게 해줍니다.

* 각 `EqualizerFilter`는 **주파수 대역**을 중심으로 신호를 처리하고, **대역폭**에 따라 필터의 적용 범위가 다르게 됩니다. 즉, 특정 주파수 대역을 강조하거나 감소시킬 수 있습니다.
* `gain` 값은 각 대역에 대한 **강조(증가)** 또는 **감소**를 제어합니다. 예를 들어, 32Hz 대역의 `gain`을 증가시키면 저주파가 강조되며, 1kHz 대역의 `gain`을 증가시키면 중고주파 대역이 강조됩니다.
* \*\*볼륨 조절기(Fader)\*\*는 필터 체인 후의 출력을 제어하여, 최종적으로 **전체 오디오의 볼륨**을 조정합니다.  

최종적으로, 이 코드의 음향적 효과는 주파수 대역별로 오디오를 조정하고, 최종 출력을 볼륨 수준에서 관리하는 것입니다. 각 밴드의 gain을 변경하여 음성이나 음악의 특성을 세밀하게 조정할 수 있습니다.

---

## 🎛 음향적 효과 요약

| 밴드 | 중심 주파수 (Hz) | 대역폭   | 용도 예시                |
| -- | ----------- | ----- | -------------------- |
| 1  | 32          | 44.7  | 저음 (킥, 베이스의 깊은 저역)   |
| 2  | 64          | 70.8  | 저음 (베이스, 킥 드럼)       |
| 3  | 125         | 141   | 저중역 (스네어 바디, 저보컬)    |
| 4  | 250         | 282   | 중역 (보컬, 기타 본체)       |
| 5  | 500         | 562   | 중고역 (현악기, 밝기)        |
| 6  | 1,000       | 1,112 | 고역 (하이햇, 심벌, 샤프한 소리) |

* 각 밴드는 다른 악기나 성분을 강조/감쇠하기 위한 대역입니다.
* 주파수 응답 조절로 음색을 커스터마이징할 수 있습니다.
