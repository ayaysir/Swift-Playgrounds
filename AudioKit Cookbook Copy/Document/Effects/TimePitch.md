# Time Pitch

`TimePitchConductor`는 **재생 중인 오디오 파일의 속도(재생률)와 음높이(피치)를 독립적으로 조절**할 수 있도록 하는 `AudioKit`의 `TimePitch` 이펙트를 제어하는 클래스입니다.

기본적으로 Apple의 `AVAudioUnitTimePitch`를 래핑한 것으로, **실시간 입력(live input)** 이나 **신호 생성기(generated signal)** 에는 작동하지 않고, **파일 기반 재생**(예: `AudioPlayer`)에만 적용됩니다.

---

## 🧠 영어 코멘트 해석과 의미

```swift
// With TimePitch you can easily change the pitch and speed of a player-generated sound.  
// It does not work on live input or generated signals.
```

> **TimePitch**를 사용하면 **플레이어에서 생성된 소리의 피치(음높이)와 속도(재생 속도)를 쉽게 변경**할 수 있습니다.
> 그러나 **실시간 입력(live input)** 또는 **오디오 생성기에서 생성된 신호**에는 작동하지 않습니다.

즉, 마이크 입력이나 오실레이터에는 적용되지 않으며, **`.mp3`, `.wav` 등 파일을 재생하는 AudioPlayer에만 적용 가능**합니다.

---

## 🎚️ 파라미터 설명

`TimePitch`는 2가지 주요 파라미터를 제공합니다.

| 파라미터    | 기본값    | 범위                           | 설명                                                                                   |
| ------- | ------ | ---------------------------- | ------------------------------------------------------------------------------------ |
| `rate`  | `2.0`  | `0.25 ... 4.0`               | **재생 속도**를 조절합니다. `1.0`은 원래 속도, `2.0`은 2배 빠르게, `0.5`는 절반 속도로 재생됩니다.                  |
| `pitch` | `-400` | `-2400 ... 2400` (센트, cents) | **음높이**를 조절합니다. `+100`은 반음(sharp), `-100`은 반음(flat)에 해당합니다. `-400`은 4반음 낮게 조정한 것입니다. |

> 🎵 **센트(cents)**: 1반음(semitone)은 100 cents.
> 따라서 `pitch = 1200`이면 한 옥타브(12음) 위로 올라갑니다.

---

## 🧪 실제 사용 예

* **보이스 체인저**: 낮은 음성(`pitch = -400`)이나 로봇 음성 효과
* **리믹스 / DJ 애플리케이션**: 속도를 올리되 음높이는 유지 (`rate ↑`, `pitch = 0`)
* **느린 연습 도구**: 속도는 줄이고 음은 그대로 (`rate = 0.5`, `pitch = 0`)

---

## 📌 요약

* `TimePitch`는 **파일 재생 음원의 피치와 속도를 독립적으로 조절**하는 이펙트입니다.
* `rate`로 **재생 속도**, `pitch`로 **음높이(센트 단위)** 를 조절합니다.
* `AVAudioUnit` 기반이라 `ramp` 애니메이션은 불가 — 즉, 값은 즉시 적용됩니다.
* **마이크나 오실레이터 등 실시간 소스에는 사용 불가**하므로, `AudioPlayer`와 함께 사용할 때만 의미가 있습니다.
