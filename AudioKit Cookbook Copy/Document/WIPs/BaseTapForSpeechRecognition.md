# Base Tap for Speech Recognition

현재 코드에서의 `SpeechRecognitionTap`과 `BaseTapForSpeechRecognitionConductor`는 **AudioKit**과 **Speech Framework**를 연결하여 실시간으로 마이크 입력을 받아 **음성 인식 결과를 텍스트로 출력**하는 역할을 수행합니다.
변경된 코드 기준으로 두 클래스의 구성과 동작을 자세히 설명드리겠습니다.

---

## ✅ `SpeechRecognitionTap`: 마이크 오디오 버퍼를 음성 인식기로 전달

```swift
class SpeechRecognitionTap: BaseTap
```

`BaseTap`은 AudioKit에서 입력을 분석하기 위한 탭(Tap)을 구현할 때 사용하는 기본 클래스입니다. `SpeechRecognitionTap`은 이를 상속받아 Apple의 `Speech` 프레임워크와 연결하는 데 초점을 둡니다.

### 🔧 주요 프로퍼티

| 프로퍼티                 | 설명                                                              |
| -------------------- | --------------------------------------------------------------- |
| `recognitionRequest` | 오디오 버퍼를 지속적으로 전달받는 객체 (`SFSpeechAudioBufferRecognitionRequest`) |
| `analyzer`           | 언어별 음성 인식기 (`SFSpeechRecognizer`)                               |
| `reconitionTask`     | 실제 인식 작업을 수행하는 비동기 작업 (`SFSpeechRecognitionTask`)               |

### 🔨 메서드 설명

#### `setupRecognition(locale:)`

```swift
func setupRecognition(locale: Locale)
```

* 선택한 언어(`Locale`)에 맞는 `SFSpeechRecognizer` 인스턴스를 생성
* 실시간 스트리밍 인식을 위한 `SFSpeechAudioBufferRecognitionRequest` 초기화
* `recognitionRequest.shouldReportPartialResults = true` 설정으로 중간 결과도 실시간 전달 가능

#### `stopRecognition()`

```swift
func stopRecognition()
```

* 음성 인식 세션을 종료하고 관련 객체를 초기화하여 해제

#### `doHandleTapBlock(buffer:at:)`

```swift
override func doHandleTapBlock(buffer: AVAudioPCMBuffer, at time: AVAudioTime)
```

* AudioKit에서 자동으로 호출되는 메서드
* 마이크 입력 버퍼를 `recognitionRequest`에 전달하여 음성 인식기가 실시간으로 처리하게 함

---

## ✅ `BaseTapForSpeechRecognitionConductor`: 음성 인식과 오디오 경로를 통합 관리

```swift
class BaseTapForSpeechRecognitionConductor: ObservableObject, HasAudioEngine
```

### 🔧 주요 프로퍼티

| 프로퍼티                                       | 설명                                    |
| ------------------------------------------ | ------------------------------------- |
| `textString`                               | 인식된 텍스트 결과                            |
| `languageCode`                             | 선택된 언어 코드 (`en-US`, `ko-KR`, `ja-JP`) |
| `srTap`                                    | `SpeechRecognitionTap` 인스턴스           |
| `engine`, `mic`, `outputMixer`, `silencer` | AudioKit의 오디오 라우팅 구성 요소               |
| `recognitionTask`                          | 음성 인식 작업 참조용                          |

### 🔨 주요 로직

#### `init()`

* 오디오 엔진과 마이크 입력 초기화
* AudioKit의 `output = silencer`로 출력 경로 설정 (실제 소리는 꺼둔 상태)
* `srTap.start()`로 마이크 데이터 수집 시작
* `setLanguage(code:)`를 호출하여 기본 언어로 음성 인식 시작

#### `setLanguage(code:)`

```swift
func setLanguage(code: String)
```

* 현재 음성 인식 세션을 중단 (`stopRecognition`, `stop`)
* 오디오 엔진을 재시작
* 새로운 언어로 `SFSpeechRecognizer`를 초기화하고 `recognitionRequest`를 설정
* `recognitionTask`를 새로 만들어 `textString`에 실시간 결과를 반영

> **핵심**: 언어가 바뀔 때 `engine`, `tap`, `recognizer`를 모두 재시작해서 새로운 인식 환경을 구성

---

## 🧠 흐름 요약

1. 뷰가 나타남 → `init()`에서 오디오 및 인식기 설정
2. 사용자가 언어를 선택 → `languageCode.didSet → setLanguage(...)`
3. 마이크 입력 → `doHandleTapBlock` → `recognitionRequest.append(...)`
4. Apple 음성 인식기에서 처리된 결과가 `textString`에 실시간 업데이트됨
5. 뷰는 `ScrollView`를 통해 자동 스크롤하며 결과를 출력

---

## 📌 정리

| 클래스                                    | 역할                       | 핵심 기능                                  |
| -------------------------------------- | ------------------------ | -------------------------------------- |
| `SpeechRecognitionTap`                 | 오디오 → SpeechFramework 전달 | 마이크 입력 버퍼를 `recognitionRequest`에 지속 전달 |
| `BaseTapForSpeechRecognitionConductor` | 오디오 엔진 + 언어 변경 + 인식기 관리  | 언어 변경 시 자동 재설정, 실시간 결과 처리              |

---

