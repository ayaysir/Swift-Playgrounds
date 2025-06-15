# 필터 (Filter)

음향에서의 \*\*필터(Filter)\*\*란, 오디오 신호에서 특정 주파수 성분을 **통과시키거나 제거하는 처리기법**입니다. 필터는 디지털 또는 아날로그 방식 모두로 구현될 수 있으며, 오디오에서 매우 중요한 역할을 합니다. 예를 들어, **원하는 음색을 만들거나, 잡음을 제거하거나, 공간감이나 특정 질감을 추가하는 데 사용됩니다.**

---

## 📘 필터의 기본 개념

### 1. **주파수(Frequency)**

* 소리는 다양한 주파수의 조합으로 이루어집니다.
* 예: 저음(20~~250Hz), 중음(250~~4kHz), 고음(4kHz\~20kHz)

### 2. **필터의 주요 기능**

* 특정 \*\*주파수 대역을 통과(Pass)하거나 제거(Cut)\*\*합니다.

### 3. **필터의 기본 분류**

| 필터 종류                          | 기능 설명                                     |
| ------------------------------ | ----------------------------------------- |
| **Low-Pass Filter**            | 특정 주파수보다 **낮은 주파수만 통과**, 고주파 제거           |
| **High-Pass Filter**           | 특정 주파수보다 **높은 주파수만 통과**, 저주파 제거           |
| **Band-Pass Filter**           | **특정 대역만 통과**하고 나머지 제거                    |
| **Band-Reject Filter** (Notch) | **특정 대역만 제거**하고 나머지 통과                    |
| **Shelf Filter**               | 특정 주파수 이상/이하를 **점진적으로 증감 (boost/cut)**    |
| **Parametric EQ**              | 중심 주파수, 폭(Q), 증감량(gain)을 조절해 특정 주파수 대역 조절 |
| **Formant Filter**             | 사람 목소리의 공명 주파수를 강조 – 보컬/로봇 보이스 등          |
| **Resonant Filter**            | 특정 주파수를 강조하여 **공명 효과** 유도                 |

---

## 🔍 공통적으로 학습해야 할 핵심 개념

각 필터 종류는 구현 방식이나 특성은 다르지만, 다음의 **공통 요소**를 갖고 있어 이를 먼저 이해하는 것이 중요합니다:

### 1. **Cutoff Frequency (컷오프 주파수)**

* 필터가 작용하기 시작하는 기준 주파수
* 대부분의 필터가 이 파라미터를 가짐

### 2. **Resonance / Q (품질 계수)**

* 필터 가장자리에 얼마나 강하게 강조 또는 감쇠할지
* 값이 높을수록 특정 주파수에서 공명(peaking) 효과가 큼

### 3. **Gain (이득)**

* 해당 대역을 얼마나 증폭하거나 줄일 것인지 (특히 EQ에서)

### 4. **Bandwidth (대역폭)**

* 중심 주파수를 기준으로 얼마나 넓은 영역을 처리할지

---

## 📚 예시를 통한 필터별 비교

| 필터명                                 | 주요 파라미터                    | 설명                            |
| ----------------------------------- | -------------------------- | ----------------------------- |
| `BandPassButterworthFilter`         | centerFrequency, bandwidth | 중심 대역만 통과 (버터워스 방식으로 급격하게 차단) |
| `BandRejectButterworthFilter`       | centerFrequency, bandwidth | 중심 대역만 제거                     |
| `EqualizerFilter`                   | gain, centerFrequency      | 기본 EQ, 단일 대역 증감               |
| `FormantFilter`                     | frequency, attackDuration  | 음성 성대 필터 특성 모방                |
| `HighPassFilter`, `LowPassFilter`   | cutoffFrequency, resonance | 단순 고역/저역 필터                   |
| `HighShelfFilter`, `LowShelfFilter` | gain, cutoffFrequency      | 특정 주파수 이상/이하 전 대역 증감          |
| `MoogLadder`                        | cutoffFrequency, resonance | 아날로그 신디사이저의 따뜻한 느낌 재현         |
| `PeakingParametricEqualizerFilter`  | centerFrequency, gain, Q   | 중심 주파수를 중심으로 양방향 증감 가능        |

---

## ✅ 실습 또는 학습 팁

1. **Dry/Wet Mix로 차이 들어보기**

   * 필터 전/후의 차이를 듣는 것이 가장 중요합니다.
   * `DryWetMixer`로 비교하면 훨씬 이해가 빠릅니다.

2. **하나씩 파라미터를 조절해보기**

   * `Frequency`, `Gain`, `Q`를 바꿔가며 효과 확인

3. **시각적 분석도 활용**

   * `FFTPlot`, `NodeOutputPlot` 같은 시각 도구로 필터 효과 확인

4. **실제 음악에 적용해보기**

   * 드럼, 보컬, 신디 등 다양한 소스에 필터를 걸어 청감 실험

---

## 🎯 요약

| 핵심 키워드                    | 설명                       |
| ------------------------- | ------------------------ |
| 필터(Filter)                | 특정 주파수 성분을 제거/강조하는 처리 도구 |
| 주파수(Frequency)            | 음향의 기본 구성 요소, 필터의 기준     |
| Cutoff / Center Frequency | 필터가 작용하는 지점              |
| Q / Resonance             | 얼마나 날카롭고 강조되는지           |
| Gain                      | 특정 주파수 대역을 얼마나 키우거나 줄일지  |

---


