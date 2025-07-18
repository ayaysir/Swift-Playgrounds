# Comb Filter Reverb

`CombFilterReverbConductor` 클래스는 `SoundpipeAudioKit`의 `CombFilterReverb` 이펙트를 사용하는 오디오 처리 클래스입니다. 이 클래스의 목적은 **콤 필터 기반의 리버브**를 드럼 소스에 적용하는 것입니다. 아래에 이 클래스와 파라미터에 대해 자세히 설명합니다.

---

## 🧠 Comb Filter Reverb란?

* **Comb Filter Reverb**는 피드백 딜레이를 기반으로 한 매우 간단한 리버브 효과입니다.
* 이름처럼 주파수 응답이 **빗살(Comb)** 모양으로 생깁니다.
* 이는 특정 주파수 성분을 **강조하거나 약화시키는 공명 패턴**을 만들어 리버브처럼 들리게 합니다.
* 일반적인 리버브보다 **알고리즘이 단순**하고 **CPU 사용량이 적음**.

---

## 🎛 파라미터 설명

| 파라미터 이름             | 기본값   | 범위              | 설명                                     |
| ------------------- | ----- | --------------- | -------------------------------------- |
| **Reverb Duration** | `1.0` | `0.0` \~ `10.0` | 잔향이 유지되는 시간 (초). 값이 클수록 리버브가 오래 지속됩니다. |

> ⚠️ 주의: `0.0`으로 설정하면 내부적으로 문제가 발생할 수 있어 **앱이 멈추거나 오작동**할 수 있습니다. 최소값은 `0.001` 이상을 권장합니다.

---

## 🧩 사용 방식

```swift
super.init(source: .drums) { input in
  CombFilterReverb(input)
}
```

* `.drums` 오디오 파일을 불러와 `CombFilterReverb`에 연결
* `BasicEffectConductor`를 상속하여 `DryWetMixer`를 통한 드라이/웻 믹싱 처리
* AudioEngine에 연결해 출력

---

## 🔊 리버브 특성

* 잔향은 **정확하고 반복적인 에코**처럼 들릴 수 있습니다.
* Feedback 기반이기 때문에 특정 주파수가 반복적으로 강조됩니다.
* 실내 공간감보다는 **딜레이와 공명** 효과에 가까운 리버브입니다.

---

## ✅ 요약

| 항목          | 설명                         |
| ----------- | -------------------------- |
| 🎧 사용 효과    | 간단한 반사음 효과, 에코처럼 반복되는 리버브  |
| 🎛 주요 조절 항목 | Reverb Duration (잔향 지속 시간) |
| ⚠️ 주의       | `0.0`으로 설정 시 오류 발생 가능      |
| 💡 적합 대상    | 드럼, 신스, 실험적인 사운드 디자인       |

---

이 효과는 자연스러운 리버브보다는 약간 **기계적이고 반복적인 공간감**을 만들어내고 싶을 때 유용합니다. `Reverb Duration` 값을 적절히 조절해 과도한 공명이 생기지 않도록 주의해야 합니다.
