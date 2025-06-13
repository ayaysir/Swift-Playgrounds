# Apple Distortion

`AppleDistortion`은 iOS/macOS의 **`AVAudioUnitDistortion`** 클래스를 활용하여 **오디오에 디지털 왜곡(distortion) 효과를 주는** Audio Unit입니다. 이는 **앰프의 과도한 증폭, 디지털 클리핑, 비선형 처리를 시뮬레이션**하며, 일반적으로 **기타, 베이스, 전자음향, 노이즈 기반 사운드 디자인** 등에 사용됩니다.

---

## 🧩 AVAudioUnitDistortionPreset란?

`AVAudioUnitDistortion`은 Apple에서 사전 설정한 여러 가지 **왜곡 효과 프리셋**을 제공합니다.
이 프리셋들은 `.loadFactoryPreset(_:)` 메서드를 통해 쉽게 사용할 수 있으며, 각각 고유의 톤과 질감을 갖고 있습니다.

---

## 📦 프리셋 목록 및 설명

| 프리셋                                                                  | 설명                                     |
| -------------------------------------------------------------------- | -------------------------------------- |
| **drumsBitBrush**                                                    | 비트 레이트 감소 + 브러시 사운드, 타악기에서 그릿(grit) 추가 |
| **drumsBufferBeats**                                                 | 텍스처와 노이즈 기반, 루프 타악기에 사용                |
| **drumsLoFi**                                                        | 낮은 해상도(Lo-Fi) 느낌의 왜곡, 필터 적용            |
| **multiBrokenSpeaker**                                               | 스피커가 망가진 듯한 거칠고 깨지는 사운드                |
| **multiCellphoneConcert**                                            | 핸드폰으로 콘서트를 녹음한 듯한 음질, 노이즈 + 압축된 음상     |
| **multiDecimated1 \~ 4**                                             | 낮은 샘플레이트와 비트뎁스로 변형된 디지털 디스토션           |
| **multiDistortedFunk**                                               | 펑키하고 압축된 기타 스타일 사운드                    |
| **multiDistortedCubed**                                              | 왜곡을 3배로 겹쳐서 매우 강한 왜곡감                  |
| **multiDistortedSquared**                                            | 왜곡을 2배로 적용한 느낌, 일반적인 강한 디스토션           |
| **multiEcho1 \~ 2**                                                  | 딜레이와 디스토션을 결합한 사운드                     |
| **multiEchoTight1 \~ 2**                                             | 딜레이가 짧아 더 타이트한 딜레이+왜곡                  |
| **multiEverythingIsBroken**                                          | 노이즈, 클리핑, 비선형성이 가득한 해체적인 사운드           |
| **speechAlienChatter**                                               | 외계인이 말하는 듯한 변조된 음성                     |
| **speechCosmicInterference**                                         | 우주 잡음, 노이즈 계열 디스토션                     |
| **speechGoldenPi**                                                   | 음성에 피치 변화와 반사감이 있는 효과                  |
| **speechRadioTower**                                                 | 라디오 수신 상태가 안 좋은 듯한 왜곡                  |
| **speechWaves**                                                      | 모듈레이션 + 미세한 디스토션으로 만든 음성 변화            |
| **speechCellphoneConcert**                                           | 핸드폰 콘서트 녹음 느낌, 로우패스+클리핑                |
| **speechDecimated**                                                  | 낮은 비트율, 디지털 음질 붕괴 느낌                   |
| **speechVocalFry**                                                   | 목소리가 갈라지는 듯한 질감                        |

---

## 🎛 각 프리셋들의 사용 예시

| 용도       | 추천 프리셋                                                     |
| -------- | ---------------------------------------------------------- |
| 기타/베이스   | multiDistortedSquared, multiBrokenSpeaker, multiDecimated2 |
| 전자음악/신스  | multiEverythingIsBroken, multiEcho1                        |
| 음성 디자인   | speechAlienChatter, speechVocalFry, speechRadioTower       |
| Lo-Fi 효과 | drumsLoFi, multiDecimated1                                 |
| 사운드 아트   | speechWaves, multiCellphoneConcert                         |

---

## ✅ 요약

* **`AppleDistortion` = AVAudioUnitDistortion**을 활용한 Apple 기본 오디오 왜곡 유닛
* **Preset은 Apple이 만든 왜곡 유형을 미리 저장한 세트**
* `multiDecimated`, `multiDistorted*`, `multiEcho*` 시리즈는 **각 효과의 강도나 세부 설정 차이만 있을 뿐, 기본 컨셉은 동일**
* 실시간으로 음원을 로딩해서 `.loadFactoryPreset(...)`으로 적용 가능

이 기능은 AudioKit에서도 래핑되어 활용되므로, 효과적으로 다양한 음향 실험을 할 수 있습니다.

