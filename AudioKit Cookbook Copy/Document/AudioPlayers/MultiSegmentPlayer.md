# MultiSegment Player

이 코드는 **AudioKit**을 기반으로 여러 오디오 파일을 연속 재생하며, 실시간 RMS 기반 시각화와 플레이헤드를 포함한 타임라인 UI를 보여주는 **멀티 세그먼트 오디오 플레이어** 구현입니다.

`MultiSegmentPlayerConductor`는 오디오 제어 로직을 담당하고, `MultiSegmentPlayerView`는 이를 화면에 표시합니다.

---

## 🧠 전체 구조 개요

* ✅ `MultiSegmentPlayerConductor`: 오디오 재생, 시간 추적, RMS 설정, 세그먼트 생성, 오디오 세션 구성 등 핵심 로직
* ✅ `MultiSegmentPlayerView`: 시각적 UI (파형, 플레이헤드, 버튼 등)
* ✅ RMS: 소리의 실제 감지 크기를 표현하는 지표 (RMS = Root Mean Square)

---

## 🔷 MultiSegmentPlayerConductor 클래스

### 1. 오디오 구성 요소

* `engine`: AudioKit의 오디오 엔진
* `player`: 세그먼트 기반의 오디오 플레이어 (여러 오디오 파일 재생 가능)

### 2. 시간 관련 변수

* `timer`: 0.05초 주기로 `checkTime()` 호출
* `timePrevious`: 이전 시간 저장 (현재 시간과 비교해 `delta time` 계산)
* `timestamp`: 재생 시간 누적값 (`@Published`로 UI와 바인딩됨)
* `endTime`: 전체 오디오 길이

### 3. RMS 시각화 제어

#### RMS (Root Mean Square)
**RMS (Root Mean Square)**는 신호의 **전반적인 에너지 크기(=지속적인 평균적인 세기)**를 나타내는 통계적 측정값입니다. 오디오에서는 "소리의 실제 감지되는 볼륨 크기"에 가까운 값으로 간주됩니다.
 - 오디오 파형은 시간에 따라 위아래로 진동하는 파형인데, 단순 평균(mean)은 0이 되기 때문에 사용이 어렵습니다.
 - 대신, 각 샘플의 제곱 → 평균 → 제곱근을 구해 전체적인 크기를 양수로 계산하는 것이 RMS입니다.
 - RMS는 Peak보다 낮지만 실제 듣는 소리의 크기와 유사합니다.

#### 변수 설명
* `rmsFramePerSecond`: 1초에 몇 개의 RMS 샘플을 만들지 결정 → 높을수록 부드러운 파형
* `pixelsPerRMS`: RMS 하나당 몇 픽셀 차지할지 → 시각화의 밀도 제어

### 4. 재생 상태 (`isPlaying`)

* `true`: 시간 초기화 후 `player.playSegments()` 호출 → 세그먼트 순차 재생 시작
* `false`: `player.stop()` → 재생 중지

---

### 5. 주요 함수

* `currentUptimeSeconds()`: 시스템 부팅 이후 경과 시간(초 단위) 계산
* `checkTime()`: 매 프레임마다 시간 흐름 계산하여 `timestamp` 업데이트
* `createSegments()`: 여러 오디오 파일을 시간차를 두고 연속 배치
* `setEndTime()`: 마지막 세그먼트의 끝 시간을 기준으로 총 길이 설정
* `setAudioSessionCategoriesWithOptions()`: 오디오 세션 설정 (스피커, 블루투스 등)
* `startAudioEngine()`: AudioKit 엔진 시작
* `setTimer()`: 타이머 시작

---

## 🔶 MultiSegmentPlayerView 구조체

### 구성 요소

* `TrackView`: RMS 기반 파형을 그리는 커스텀 뷰
* `Rectangle()`: 플레이헤드 (현재 재생 위치를 나타내는 빨간 선)
* `PlayPauseButton`: 재생/일시정지 버튼 (아이콘 변경)
* `currentTimeText`: 현재 시간과 총 시간 표시 (`"2.4 of 4.7"` 형식)

### 핵심 연산 프로퍼티

```swift
var currentPlayPosition: CGFloat {
  let pixelsPerSecond = conductor.pixelsPerRMS * conductor.rmsFramePerSecond
  return conductor.timestamp * pixelsPerSecond - playheadWidth
}
```

* `timestamp`를 픽셀 단위 위치로 환산 → 플레이헤드를 왼쪽으로 이동시킴
* `playheadWidth`만큼 왼쪽으로 보정해서 중앙 정렬

---

## 🔧 실행 흐름 요약

1. `onAppear` 시 `conductor.start()` → 오디오 엔진 시작
2. `Play` 누르면 `isPlaying = true` → `player.playSegments()` 실행 + `timestamp` 시작
3. `Timer`가 `checkTime()`을 주기적으로 호출 → `timestamp` 증가
4. `timestamp` 값에 따라 플레이헤드 위치 및 시간 텍스트 실시간 갱신
5. RMS 파형은 `TrackView`에서 표시됨 (코드 미포함)

---

## 🎯 이 코드가 하는 일

* 다수의 오디오 파일을 시간차를 두고 이어붙여 순차 재생
* RMS 기반 시각화 구현을 위한 값 설정
* 재생 시간에 따라 플레이헤드를 이동
* SwiftUI UI와 오디오 재생이 실시간으로 연동

---
