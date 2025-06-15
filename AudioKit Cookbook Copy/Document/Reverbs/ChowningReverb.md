# Chowning Reverb

`ChowningReverbConductor` 클래스는 AudioKit의 `ChowningReverb` 리버브 효과를 적용하고 제어하는 SwiftUI 기반 오디오 컨덕터 클래스입니다. 구조와 작동 방식을 자세히 설명하겠습니다.

---

## 🧠 1. 클래스의 역할

```swift
class ChowningReverbConductor: BasicEffectConductor<ChowningReverb>
```

이 클래스는 `BasicEffectConductor`의 제네릭 서브클래스로, `<ChowningReverb>` 타입을 사용합니다. 즉:

* **ChowningReverb** 효과를 오디오 신호에 적용하고
* **UI에서 제어 가능하도록 상태를 바인딩**하며
* 기본 오디오 소스로 `.drums`를 사용합니다.

---

## 🎛️ 2. ChowningReverb란?

`ChowningReverb`는 \*\*존 초우닝(John Chowning)\*\*이 설계한 초기 디지털 리버브 알고리즘을 기반으로 만들어진 리버브입니다.

* \*\*FAUST 및 CLM (Common Lisp Music)\*\*에서 유래한 고전적인 알고리즘 기반 리버브
* **알고리즘 리버브**의 초기 형태로, 빠르고 가벼운 잔향 처리 가능
* 복잡한 리버브보다 CPU 부담이 적음

> **참고**: John Chowning은 FM 합성을 발명한 인물로, 디지털 사운드 신디시스 분야의 선구자입니다.

---

## 🎚️ 3. 파라미터 설명

```text
Balance | 1.0 | 0.0...1.0
```

* **Balance**: 리버브의 **드라이/웻 믹스** 정도를 제어합니다.

  * `0.0` → 원본 소리만 들림 (Dry)
  * `1.0` → 리버브 처리된 소리만 들림 (Wet)
  * `0.5` → 두 신호가 반반 섞임

이 값은 내부적으로 `DryWetMixer`와 유사하게 작동합니다.

---

## ⚙️ 4. 코드 흐름 요약

```swift
super.init(source: .drums) { input in
  ChowningReverb(input)
}
```

* `.drums` 샘플을 불러와 플레이어로 재생
* `ChowningReverb` 이펙트를 플레이어에 연결
* 오디오 신호에 리버브를 적용한 뒤 출력

---

## ✅ 요약

| 항목      | 설명                         |
| ------- | -------------------------- |
| 🎧 효과   | 디지털 리버브 (Chowning 알고리즘 기반) |
| ⚙️ 파라미터 | `balance` (드라이/웻 믹스 비율)    |
| 📦 모듈   | `SoundpipeAudioKit`        |
| 🔄 용도   | 빠르고 간단한 잔향 효과, CPU 사용량 적음  |

이 리버브는 리소스가 제한된 환경이나 간단한 앰비언스 처리를 원할 때 적합합니다.
