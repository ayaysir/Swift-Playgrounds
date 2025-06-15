# Filter의 Node 목록

---

## 🔵 AudioKit 필터

### 🎛 HighPassFilter

* **기능**: 지정된 컷오프 주파수 이하의 저역을 제거하고 고역을 통과시킴.
* **Cutoff Frequency**

  * 필터가 작동을 시작하는 기준 주파수
  * 값이 높을수록 더 많은 저역이 제거됨
* **Resonance**

  * 컷오프 근처의 주파수를 강조하는 정도
  * 값이 높을수록 해당 경계가 날카롭고 뚜렷하게 들림

---

### 🎛 HighShelfFilter

* **기능**: 특정 주파수 이상 대역을 증폭 또는 감쇠 (고역 쉘프 필터)
* **Cut Off Frequency**

  * 고역 증감이 시작되는 지점
* **Gain**

  * 해당 대역을 얼마나 키울지 또는 줄일지
  * 양수: 고역 강조 / 음수: 고역 약화

---

### 🎛 LowPassFilter

* **기능**: 컷오프 주파수 이상을 제거하고 저역을 통과시킴
* **Cutoff Frequency**

  * 고역 차단 시작 지점
  * 값이 낮을수록 더 많은 고역이 제거됨
* **Resonance**

  * 컷오프 주파수 부근을 얼마나 강조할지
  * 값이 클수록 더 뾰족한 음색을 생성

---

### 🎛 LowShelfFilter

* **기능**: 특정 주파수 이하의 저역을 증폭 또는 감쇠
* **Cutoff Frequency**

  * 저역 증감이 시작되는 기준 주파수
* **Gain**

  * 양수일 경우 저음 강화 / 음수일 경우 저음 감소

---

## 🔷 SoundpipeAudioKit 필터

### 🎛 BandPassButterworthFilter

* **기능**: 특정 대역만 통과시키고 그 외는 차단 (부드러운 버터워스 특성)
* **Center Frequency**

  * 통과시킬 중심 주파수
* **Bandwidth**

  * 통과 대역폭 (넓을수록 많은 대역 허용)

---

### 🎛 BandRejectButterworthFilter

* **기능**: 특정 대역만 제거하고 그 외는 통과 (노치 필터)
* **Center Frequency**

  * 제거 대상 중심 주파수
* **Bandwidth**

  * 제거 대역폭 (값이 클수록 넓은 영역이 제거됨)

---

### 🎛 EqualizerFilter

* **기능**: 특정 대역만 조정 가능한 기본 이퀄라이저
* **Center Frequency**

  * 조절할 중심 주파수
* **Bandwidth**

  * 영향을 주는 대역폭 범위
* **Gain**

  * 해당 대역을 증폭(+)/감쇠(-) 정도

---

### 🎛 FormantFilter

* **기능**: 인간 목소리의 공명 구조(포먼트)를 모방해 로봇 보이스나 보컬 이펙트에 활용
* **Center Frequency**

  * 포먼트 중심 주파수
* **Attack Duration**

  * 필터 적용 시 올라가는 속도 (빠를수록 즉각적 반응)
* **Decay Duration**

  * 효과가 사라지는 속도 (느릴수록 잔향 느낌)

---

### 🎛 HighPassButterworthFilter

* **기능**: 저역을 부드럽게 제거하는 고역 필터
* **Cutoff Frequency**

  * 저역 차단 시작 지점 (값이 높을수록 더 많은 저역 제거)

---

### 🎛 HighShelfParametricEqualizerFilter

* **기능**: 고역대 쉘프 필터에 정밀 제어를 더한 필터
* **Corner Frequency**

  * 고역 증감이 시작되는 주파수
* **Gain**

  * 고역을 얼마나 증폭하거나 감쇠할지
* **Q**

  * 변화가 일어나는 영역의 폭 (값이 작을수록 완만)

---

### 🎛 KorgLowPassFilter

* **기능**: Korg 스타일의 필터로, 아날로그 특성 및 왜곡 포함
* **Filter Cutoff**

  * 고역 차단 시작점
* **Resonance**

  * 컷오프 부근 강조 정도
* **Saturation**

  * 왜곡량 조절 (값이 높을수록 따뜻하고 거친 소리)

---

### 🎛 LowPassButterworthFilter

* **기능**: 부드럽게 고역을 제거하는 저역 필터
* **Cutoff Frequency**

  * 고역 차단 시작 지점

---

### 🎛 LowShelfParametricEqualizerFilter

* **기능**: 저역대 쉘프 필터 + Q 제어 추가
* **Corner Frequency**

  * 저역 증감이 시작되는 주파수
* **Gain**

  * 저역 증폭/감쇠 정도
* **Q**

  * 변화 범위의 폭

---

### 🎛 ModalResonanceFilter

* **기능**: 특정 주파수를 공명시켜 금속/현악 느낌을 부여
* **Resonant Frequency**

  * 공명 중심 주파수
* **Quality Factor**

  * 공명의 날카로움 (값이 높을수록 뾰족하고 긴 울림)

---

### 🎛 MoogLadder

* **기능**: Moog 신시사이저의 Ladder 필터 모델링, 따뜻한 아날로그 느낌
* **Cutoff Frequency**

  * 고역 차단 지점
* **Resonance**

  * 컷오프 근처 강조 (값이 높을수록 더 신디사이저 느낌)

---

### 🎛 PeakingParametricEqualizerFilter

* **기능**: 특정 대역만 강조하거나 감쇠 (중심 대역 이퀄라이저)
* **Center Frequency**

  * 조절할 중심 주파수
* **Gain**

  * 해당 대역 증폭/감쇠 정도
* **Q**

  * 영향받는 대역의 넓이

---

### 🎛 ResonantFilter

* **기능**: 특정 주파수를 공명시키고 나머지는 억제
* **Frequency**

  * 공명 주파수
* **Bandwidth**

  * 공명 폭 (넓을수록 효과가 부드러움)

---

### 🎛 ThreePoleLowpassFilter

* **기능**: 3단계 구조의 저역 필터, 왜곡 포함
* **Distortion**

  * 추가적인 음색 변형
* **Cutoff Frequency**

  * 고역 차단 시작점
* **Resonance**

  * 공명 강조 정도

---

### 🎛 ToneComplementFilter

* **기능**: `ToneFilter`의 보완적 역할을 하는 필터
* **Half-Power Point**

  * 주파수 응답이 절반으로 줄어드는 기준 지점

---

### 🎛 ToneFilter

* **기능**: 고역/저역에 일정한 감쇠 효과를 줘서 톤 정리
* **Half-Power Point**

  * 필터가 가장 많이 작용하는 중심 지점

---


