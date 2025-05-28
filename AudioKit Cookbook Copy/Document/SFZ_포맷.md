# SFZ 포맷

**SFZ 파일**은 **가상 악기용 샘플 기반 음원**을 정의하는 **텍스트 기반 포맷**입니다. 주로 \*\*샘플러(VSTi 등)\*\*에서 다양한 악기 소리를 재생하기 위해 사용됩니다.

---

## 🔍 SFZ란?

* **확장자:** `.sfz`
* **형식:** 텍스트(ASCII)
* **역할:** 오디오 샘플(WAV 등)의 **배치/맵핑 정보**를 정의
* **개발자:** Cakewalk (RGC\:audio)

---

## 🎵 어떻게 동작하나요?

1. 여러 개의 **WAV 샘플**이 있음 (예: 각 음정별로 녹음된 피아노 소리).
2. `sound.sfz` 파일에서 각 샘플을 **어떤 음정, 어떤 속도, 어떤 벨로시티**에서 재생할지를 정의.
3. 샘플러(예: Sforzando, ARIA, Kontakt 등)가 `.sfz`를 읽어 악기처럼 재생.

예시:

```sfz
<region>
sample=note_C4.wav
lokey=60
hikey=60
pitch_keycenter=60
```

이건 C4(MIDI 60)에서만 `note_C4.wav` 샘플이 재생되도록 설정한 예입니다.

---

## 📌 SFZ의 특징

| 장점                 | 단점                    |
| ------------------ | --------------------- |
| 텍스트 기반으로 가볍고 수정 쉬움 | GUI 지원 부족 (직접 코딩해야 함) |
| 무료 사용 및 확장 용이      | 복잡한 기능은 표현에 제약이 있음    |
| 다양한 무료/유료 라이브러리 존재 | 제작 시 구조를 잘 이해해야 함     |

---

## 🔧 어디에 쓰이나요?

* 디지털 오디오 워크스테이션(DAW)에서 가상악기 로딩
* 무료/오픈소스 샘플러에서 악기 정의
* 게임 사운드 또는 개인 음악 제작용

---

## 🧾 코드 예제

```sfz
<group>lokey=0 hikey=127 pitch_keycenter=57 pitch_keytrack=100
<region>lovel=000 hivel=127 amp_velcurve_127=1 loop_mode=loop_continuous loop_start=0 loop_end=220 sample=basicSamples/saw220.wav
```

---

### 🔍 해설

#### 1. `<group>` 라인

```sfz
<group>lokey=0 hikey=127 pitch_keycenter=57 pitch_keytrack=100
```

* **`<group>`**: 이 뒤에 오는 `<region>`들에 공통으로 적용될 설정을 정의합니다.
* **`lokey=0`**: 이 그룹의 음역 최소값은 MIDI 키 0 (C-1)입니다.
* **`hikey=127`**: 최대값은 MIDI 키 127 (G9)입니다. → **모든 건반에 적용됨**
* **`pitch_keycenter=57`**: 이 샘플의 **기준 피치**는 MIDI 57 (A3)입니다.
* **`pitch_keytrack=100`**: **피치 트래킹 100%** → 누르는 키에 따라 **정확히 해당 음정으로 피치 변경**됩니다.

---

#### 2. `<region>` 라인

```sfz
<region>lovel=000 hivel=127 amp_velcurve_127=1 loop_mode=loop_continuous loop_start=0 loop_end=220 sample=basicSamples/saw220.wav
```

* **`<region>`**: 실제 샘플을 매핑하는 설정입니다.
* **`lovel=000` / `hivel=127`**: 이 region은 **모든 velocity(세기)** 구간(0\~127)에서 작동합니다.
* **`amp_velcurve_127=1`**: velocity가 127일 때는 \*\*볼륨 1.0(최대)\*\*로 재생됩니다.
  → velocity에 따른 **볼륨 곡선**을 정의하는 파라미터.
* **`loop_mode=loop_continuous`**: 샘플을 **끝없이 루프 재생**합니다.
* **`loop_start=0`** / **`loop_end=220`**: **0프레임부터 220프레임까지** 루프합니다.
  → wav 파일 내에서 해당 영역이 반복됨.
* **`sample=basicSamples/saw220.wav`**: 실제 재생할 **샘플 파일 경로**입니다.
  → `basicSamples` 폴더에 있는 `saw220.wav`라는 웨이브 파일 사용.

---

### 🎹 결과적으로 어떤 소리가 나나요?

* 사용자가 어떤 키를 누르든 (`0~127`), 어떤 velocity로 누르든 (`0~127`)
* **`saw220.wav`** 파일이 기준음 A3로 pitch-shift 되어 재생됨.
* 소리는 **0\~220 프레임 사이를 무한 루프**하며 지속됨.
* velocity가 클수록 소리 크기는 커짐 (최대 127에서 1.0)

---



