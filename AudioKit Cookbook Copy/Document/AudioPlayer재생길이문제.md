# AudioPlayer 재생 길이 문제

```plain
Q. 코드에서 음원 파일을 로딩해서 재생하는 기능이 있는데 재생 길이가 들쭉날쭉한데 (어쩔 떄는 전체 재생하는데, 어쩔 떄는 중간에 끊김) 해결방법은?
A. Buffer 문제 가능성일 수 있음 ❌
Q.conductor.player.buffer 를 nil 로 하더라도 동일한 문제가 발생하는데 다른 곳에 문제는 없음?
```

## 맞는 답변

`conductor.player.buffer = nil`로 설정해도 문제가 동일하게 발생한다면, 문제는 버퍼 자체보다는 **`player.file`과 `player.buffer`의 동시 사용 방식** 또는 **`AVAudioEngine`의 연결 구조**에 있을 가능성이 높습니다. `AudioPlayer`는 `buffer` 또는 `file` 중 하나만 사용할 수 있으며, **둘을 동시에 설정하면 예기치 못한 동작**(중간에 끊김 등)이 발생할 수 있습니다.

---

### ✅ AudioKit `AudioPlayer` 동작 방식 요약

| 설정된 값         | 동작 방식                    |
| ------------- | ------------------------ |
| `.file`만 설정   | 스트리밍 재생 (긴 오디오에 적합)      |
| `.buffer`만 설정 | 메모리에 올려서 재생 (짧은 클립에 적합)  |
| **둘 다 설정**    | ⚠️ 비권장 — 예기치 않은 문제 발생 가능 |

---

### 🔍 지금 코드의 의심 지점

```swift
conductor.player.file = try? AVAudioFile(forReading: url)
conductor.player.isLooping = true
conductor.player.buffer = buffer
```

위처럼 `file`과 `buffer`를 **동시에 설정하면 충돌** 가능성이 있습니다.

#### 추가

##### Effects 코드의 오디오 플레이어 설정 방법

버퍼만 설정

```swift
buffer = Cookbook.sourceBuffer(source: defaultSource)
player.buffer = buffer
player.isLooping = true
```

##### 기존 PlayersControl 코드

버퍼 + 오디오 파일 설정이 추가?

```swift
conductor.player.file = try? AVAudioFile(forReading: url) // <- ??
conductor.player.isLooping = true
conductor.player.buffer = buffer
```

---

### ✅ 해결 방법

#### 방법 1: **`file`을 지우고 `buffer`만 사용 ☑️  **

```swift
conductor.player.stop()
conductor.player.file = nil // file은 사용하지 않음
conductor.player.buffer = buffer
conductor.player.isLooping = true
```

#### 방법 2: **`file`만 사용하고 `buffer`는 설정하지 않음 ❌ **

```swift
conductor.player.stop()
conductor.player.buffer = nil // buffer는 사용하지 않음
conductor.player.file = try? AVAudioFile(forReading: url)
conductor.player.isLooping = true
```

둘 중 하나만 사용하세요.

---

### 📌 추가 확인 사항

* `engine.output`이 올바르게 연결되어 있는지 (`AudioPlayer`가 output chain에 포함되어야 함)
* `buffer.frameLength`가 실제 음원 길이와 일치하는지 (짧게 잘려 있지 않은지)
* `.play()` 이후에 `isPlaying`이 `true`인지 확인 (`player.isPlaying` 체크)

---

### 🧪 디버깅 팁

```swift
Log("buffer length:", buffer.frameLength)
Log("buffer duration:", buffer.frameLength / buffer.format.sampleRate)
```

또는

```swift
Log("file duration:", file.length / file.processingFormat.sampleRate)
```

을 통해 실제 재생되는 길이를 확인하세요.

---

### ✅ 결론

`buffer`와 `file`은 **동시에 쓰면 안 됩니다.** 둘 중 하나만 설정해야 하고, **중간에 끊김 문제가 있다면 이중 설정을 제거**하는 것부터 확인해야 합니다.
