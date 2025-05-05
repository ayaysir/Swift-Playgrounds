# Audio3D

이 코드는 **3D 오디오 시뮬레이션과 시각화를 구현하는 SwiftUI 앱**입니다. 주된 목표는 사용자의 시점(Camera)과 음원(Source)의 위치에 따라 오디오 환경이 실제처럼 동적으로 반응하도록 만드는 것입니다. 핵심은 `AudioEngine3DConductor`와 `SceneCoordinator`이며, 두 객체는 각각 **오디오 처리**와 **3D 장면 좌표 추적 및 업데이트** 역할을 맡습니다.

---

## 🔊 `AudioEngine3DConductor` – 오디오 엔진 및 3D 사운드 구성

`AudioEngine3DConductor`는 오디오 엔진을 설정하고, 3D 공간에서 위치 기반 사운드를 처리합니다. `UpdateAudioSourceNodeDelegate` 프로토콜을 구현하여 외부에서 전달되는 **카메라와 음원의 위치 및 방향**에 따라 엔진 내 3D 사운드 정보를 갱신합니다.

### 주요 구성 요소
- `engine`: `AudioKit`의 메인 오디오 엔진
- `player`: 루프 재생 가능한 `AudioPlayer`
- `source1Mixer3D`: 3D 공간 내 위치 조절이 가능한 `Mixer3D`
- `environmentalNode`: 3D 환경 효과를 제공하는 노드 (`AVAudioEnvironmentNode` 기반)

### 설정 흐름
1. `player`에 `buffer`를 할당하고 루프 재생 설정
2. `player`를 `Mixer3D`에 연결하고, 이 Mixer를 `EnvironmentalNode`에 연결
3. `EnvironmentalNode`는 공간 처리 알고리즘과 리버브 설정
4. 최종적으로 `engine.output = environmentalNode`로 출력 설정

### 위치/방향 갱신
- `updateListenerPosition3D`: 리스너(카메라)의 위치 갱신
- `updateListenerOrientationVector`: 리스너의 방향(벡터 기반) 갱신
- `updateSoundSourcePosition`: 사운드 소스 위치 갱신

---

## 🎥 `SceneCoordinator` – SceneKit 기반 3D 공간의 상태 추적

`SceneCoordinator`는 SceneKit의 3D 장면을 제어하며, 오디오 위치에 반영될 정보를 추출합니다. `SCNSceneRendererDelegate`를 채택해 매 프레임마다 위치와 방향을 추적하고 이를 `AudioEngine3DConductor`에 전달합니다.

### 주요 구성 요소
- `theScene`: 로딩된 `.scn` 파일로 구성된 3D 장면
- `cameraNode`: 카메라의 위치를 3D 공간 내에서 설정
- `updateAudioSourceNodeDelegate`: 위치 정보 전달용 delegate (보통 `AudioEngine3DConductor`)

### 렌더링 시 위치 업데이트
`renderer(_:updateAtTime:)`에서 다음 작업을 수행합니다:
1. 장면에서 `pointOfView` (카메라 위치)와 `"soundSource"` 노드의 위치를 가져옴
2. `updateAudioSourceNodeDelegate`를 통해 이 정보를 `AudioEngine3DConductor`에 전달

---

## 🧩 기타 구성 요소 (간단 요약)

### `AudioKit3DViewModel`
- `@Observable` 클래스
- `AudioEngine3DConductor`와 `SceneCoordinator`를 생성 및 연결

### `AudioKit3DView`
- SwiftUI 뷰
- 뷰 모델을 통해 오디오 및 SceneView 구성
- `.onAppear` / `.onDisappear`에서 오디오 재생/중지 제어

---

## 정리

| 역할                  | 담당 클래스                | 주요 기능 |
|---------------------|-------------------------|-----------|
| 오디오 처리 및 3D 반영 | `AudioEngine3DConductor` | 플레이어, 3D 믹서, 위치 반영 |
| 3D 장면 제어 및 추적   | `SceneCoordinator`       | 카메라 및 음원 위치 추적 후 오디오 엔진에 전달 |
| 데이터 조율          | `AudioKit3DViewModel`    | 두 객체 연결 |
| UI 렌더링             | `AudioKit3DView`         | SceneKit 뷰 표시 및 조작 |

이 시스템은 **SceneKit의 위치 정보를 기반으로 AudioKit의 3D 오디오를 실시간 반영하는 구조**입니다. 따라서 사용자의 시점이 변하면 오디오도 그에 맞춰 동적으로 바뀝니다.

---

## sourceBuffer의 역할

`sourceBuffer`는 3D 공간에서 재생할 **오디오 데이터의 원본** 역할을 합니다. 구체적으로는, 오디오 파일 `"Samples/beat.aiff"`를 앱 번들에서 불러와 `AVAudioPCMBuffer` 형식으로 메모리에 로드하고, 이후 `AudioPlayer`가 이 버퍼를 기반으로 사운드를 재생하게 됩니다.

---

### 🔍 핵심 역할 요약

| 항목 | 설명 |
|------|------|
| 🎵 버퍼의 정체 | `AVAudioPCMBuffer`: 오디오 프레임들을 담고 있는 PCM 형식의 버퍼 |
| 📂 데이터 출처 | 번들에 포함된 `"Samples/beat.aiff"` |
| 🎧 사용 위치 | `AudioEngine3DConductor`의 `player.buffer = buffer`에서 할당되어 재생 |
| 🔁 특성 | `player.isLooping = true`로 설정되어 반복 재생됨 |

---

### 🧠 왜 버퍼를 쓰는가?

- `AVAudioPlayer`나 `AVAudioEngine`에서 **짧은 오디오 클립을 빠르게 재생하거나 반복 재생**할 때, 파일 스트리밍보다 버퍼 방식이 효율적입니다.
- `AVAudioPCMBuffer`는 **RAM에 오디오 데이터를 미리 올려놓는 방식**이므로 지연(Latency) 없이 즉시 재생이 가능합니다.
- 공간 오디오 처리에서는 오디오 위치가 실시간으로 변경될 수 있기 때문에, 버퍼 기반의 반복 재생이 적합합니다.

---

즉, `sourceBuffer`는 앱이 사용할 사운드를 **메모리에 로드된 상태로 유지하며**, 3D 위치 기반 재생을 가능하게 해주는 핵심 데이터 소스입니다.

---

## Observable 동작원리
- [문서](./Observable%20동작원리.md)
