# Convolution

이 코드는 AudioKit과 SoundpipeAudioKit을 사용해 **컨볼루션 리버브(Convolution Reverb)** 효과를 구현한 예제입니다. 특히, **두 개의 다른 임펄스 응답(Impulse Response)** 파일을 혼합하여 사용자 지정 리버브 환경을 만드는 것이 핵심입니다.

---

## 🔊 핵심 개념 요약

### 🔹 Convolution

* **Convolution Reverb**는 **실제 공간에서 녹음된 '임펄스 응답(Impulse Response)'과 입력 오디오 신호를 \*\*곱셈-합산 연산(convolution)\*\*하여, **실제 공간의 리버브를 시뮬레이션**합니다.
* 입력 오디오와 IR 파일을 합성(convolve)하여 **현실적인 반향 효과**를 구현합니다.

---

### 📌 간단 정리

| 용어                          | 설명                                                              |
| --------------------------- | --------------------------------------------------------------- |
| **Convolution**             | 입력 신호와 임펄스 응답(IR)을 수학적으로 합성하여 실제 공간과 유사한 반향을 만드는 과정             |
| **Impulse Response (IR)**   | 특정 공간에서 “짧고 강한 소리”(예: 박수)를 녹음한 오디오 파일. 공간의 잔향 특성을 포함            |
| **Ftable (Function Table)** | AudioKit과 같은 DSP 환경에서 사용하는 **신호 데이터 테이블**, 예: 샘플/파형/IR 등을 담은 배열 |

---

### 🎛️ Convolution 클래스 정의

```swift
// This module will perform partitioned convolution on an input signal using an ftable as an impulse response.
```

* **input signal**: 마이크, 음원 등의 오디오 신호
* **ftable**: 임펄스 응답 데이터를 담고 있는 **파형 테이블**, 흔히 `.wav` 파일에서 변환됨
* **partitioned convolution**: IR을 여러 작은 조각으로 나눠 계산해 **CPU 부하를 줄이고 지연(latency)을 줄이는 방식**

---

### 🔉 예시로 이해하기

* 당신이 `플루트 소리`를 건물 계단실에서 연주했다고 가정
* 실제 계단실에서 녹음된 **IR (Impulse Response)** 파일: `stairwell.wav`
* AudioKit의 `Convolution`은:

  > 입력된 플루트 소리를 `stairwell.wav`의 ftable과 합성해,
  > 마치 그 계단실에서 직접 플루트를 연주한 것처럼 들리게 함

---

### 💡 왜 ftable을 쓰는가?

* 오디오를 실시간 처리하기 위해선 **미리 처리된 IR 데이터를 배열(테이블)로 변환**하는 게 효율적
* 이 테이블을 기반으로 빠르게 수학적 곱셈/합산 연산을 진행할 수 있음

---

## 🧱 구조 및 동작 흐름

### 1. 🔧 `ConvolutionData`

```swift
struct ConvolutionData {
  var dryWetMix: AUValue = 0.5
  var stairwellDishMix: AUValue = 0.5
}
```

* `dryWetMix`: 원본 소리(player)와 리버브 처리된 소리(믹서 출력) 간 비율.
* `stairwellDishMix`: 두 리버브 (`stairwell`, `dish`) 간 비율.

---

### 2. 🛠️ 임펄스 응답 파일 불러오기

```swift
let stairwellURL = ...
let dishURL = ...
```

* 각각의 리버브 환경을 묘사하는 `.wav` 파일

  * **stairwell.wav**: 계단실과 같은 큰 공간 느낌
  * **dish.wav**: 금속성 또는 특이한 잔향 느낌

---

### 3. 🔄 Convolution 효과 구성

```swift
stairwellConvolution = Convolution(player, impulseResponseFileURL: stairwellURL, partitionLength: 8192)
dishConvolution = Convolution(player, impulseResponseFileURL: dishURL, partitionLength: 8192)
```

* `partitionLength`: 처리 블록 크기. **값이 작을수록 지연은 줄지만 CPU 사용률이 증가**
* 두 개의 서로 다른 공간 리버브 효과 생성

---

### 4. 🔀 DryWetMixer 체인

```swift
stairwellDishMixer = DryWetMixer(stairwellConvolution, dishConvolution, balance: 0.5)
dryWetMixer = DryWetMixer(player, stairwellDishMixer, balance: 0.5)
engine.output = dryWetMixer
```

* **리버브 A와 B를 섞은 결과 → 원본과 또 섞음**
* 최종 출력은 `dryWetMixer`

```plaintext
     [Player]
        │
 ┌─────┴─────┐
 ▼           ▼
Stairwell   Dish
  │           │
  └─────┬─────┘
        ▼
 stairwellDishMixer
        │
        ▼
   dryWetMixer (← player)
        │
     [Engine Output]
```

---

### 7. 🧪 리버브 활성화

```swift
stairwellConvolution.start()
dishConvolution.start()
```

* AudioKit의 `Node`는 사용 전 `.start()` 필수

---

## 🧩 요약

| 요소                   | 설명                    |
| -------------------- | --------------------- |
| `player`             | 오디오 재생용               |
| `Convolution`        | IR 기반 리버브 처리          |
| `stairwellDishMixer` | 두 리버브를 섞는 믹서          |
| `dryWetMixer`        | 원본과 리버브를 섞는 믹서        |
| `data`               | 두 믹서의 balance를 실시간 제어 |

---

## 📌 활용 예시

* 게임에서 공간 이동에 따른 잔향 효과
* 음악에서 마이크 녹음 시 실제 공간 질감 추가
* Foley 사운드 제작

---

