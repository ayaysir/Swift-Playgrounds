# Drum Synthesizers

---

## 📦 클래스 개요

이 클래스는 **AudioKit** 기반의 킥/스네어 드럼 신스 루프를 생성하고 반복 재생하는 **미니 드럼 머신**입니다.

---

## 🧱 주요 멤버 구성

| 속성명             | 설명                                          |
| --------------- | ------------------------------------------- |
| `engine`        | `AudioEngine` 인스턴스. 오디오 처리의 핵심 엔진           |
| `kick`, `snare` | 각각 킥과 스네어 드럼 사운드를 생성하는 신스 객체                |
| `reverb`        | 믹서 출력에 리버브 효과 추가                            |
| `counter`       | 현재 루프 반복 횟수 (비트 단위로 증가)                     |
| `bpm`           | 현재 템포 (기본: 120 BPM)                         |
| `loop`          | `CallbackLoop` 객체. 지정된 frequency(Hz)로 콜백 실행 |
| `isRunning`     | 재생 여부 (true일 때 루프 시작, false일 때 정지)          |

---

## 🔁 `loop` 정의

```swift
CallbackLoop(frequency: bpm / 60 * 4)
```

* `bpm / 60` → **초당 박자 수 (beats per second)**
* `× 4` → **16분음표 단위 실행을 위해 한 박자를 4개로 나눔**

  * 예: BPM이 120이면 `120 / 60 * 4 = 8Hz`, 즉 **0.125초마다 실행**

---

## 🥁 루프 내부 동작

루프는 약 0.125초마다 실행되며, 매 반복마다 다음을 수행합니다:

| 조건                                | 설명                | 동작             |
| --------------------------------- | ----------------- | -------------- |
| `counter % 4 == 0`                | **1박자마다**         | 킥 드럼 실행        |
| `counter % 8 == 0`                | **2박자마다**         | 스네어 드럼 실행      |
| `counter % 2 == 0 && random == 0` | **랜덤 킥 추가 (25%)** | 킥 드럼 실행 가능성 추가 |
| `counter += 1`                    | 매 반복마다 1 증가       | 박자 흐름 추적용      |

> → 16분음표 단위로 루프가 반복되며, 4개마다 1박자로 계산됨 (즉, 4로 나눈 나머지를 통해 박자 추적)

---

## 🎛️ `isRunning`

```swift
@Published var isRunning = false {
  didSet {
    isRunning ? loop.start() : loop.stop()
  }
}
```

* 이 프로퍼티를 통해 외부에서 루프의 시작/정지를 트리거할 수 있음 (예: 버튼 바인딩)

---

## 🛠️ `init()`

```swift
let mixer = Mixer(kick, snare)
reverb = Reverb(mixer)
engine.output = reverb
```

* 킥과 스네어를 믹싱 후 리버브를 거쳐 최종 출력
* `engine.output`에 연결되어 실제 소리가 나도록 설정

---

## BPM으로부터 Frequency(Hz) 도출

`CallbackLoop(frequency:)`에 전달하는 **frequency(Hz)** 는 1초에 몇 번 콜백할지를 의미합니다.
이걸 BPM과 리듬 단위로 바꾸려면 다음 공식을 사용할 수 있습니다:

---

### ✅ 공식

```
frequency = (BPM / 60) × 분기 단위 비율
```

예를 들어:

| 리듬 단위   | 분기 단위 비율 |
| ------- | -------- |
| 4분음표마다  | 1        |
| 8분음표마다  | 2        |
| 16분음표마다 | 4        |
| 32분음표마다 | 8        |

---

### 🎯 예시: BPM 90에서 16분음표 단위로 루프 돌리기

```
frequency = (90 / 60) × 4 = 6
```

→ `CallbackLoop(frequency: 6)` 으로 설정

---

### ⏱ 일반화 함수

```swift
func frequency(for bpm: Double, division: Int) -> Double {
  return (bpm / 60.0) * Double(division)
}
```

* `division`: 1 = 4분음표, 2 = 8분음표, 4 = 16분음표 …

---

## ✅ 요약

* 120 BPM 기준 **16분음표 단위 루프 (0.125초마다 실행)**
* **kick**: 매 박자마다 + 25% 확률로 중간에 추가
* **snare**: 두 박자마다 (4박 기준으로 2, 4 위치에서 주로 등장)
* `counter`를 통해 타이밍 제어
* `CallbackLoop(frequency:)`를 템포에 맞춰 계산하여 정확한 리듬 유지

---
