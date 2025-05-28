# Sprite Kit Audio

이 코드는 **SpriteKit과 AudioKit을 결합한 인터랙티브 사운드 예제**입니다. 사용자가 화면을 터치하면 공이 생성되고, 플랫폼에 부딪히면 소리가 나는 구조입니다. 주요 구성요소별로 설명드리겠습니다.

---

## ✅ 전반적 구조

* `SpriteKit`을 이용해 물리 기반 애니메이션 처리
* `AudioKit`을 이용해 플랫폼에 충돌 시 음향 재생
* `SwiftUI`에서 `SpriteView`로 SpriteKit 장면을 보여줌

---

## 1. **GameScene (SKScene + 물리 처리)**

### `didMove(to:)`

* 장면 초기 설정
* `physicsWorld.contactDelegate = self`
  → 충돌 감지 델리게이트 설정
* `physicsBody = edgeLoopFrom:`
  → 화면 가장자리를 물리적으로 막는 **테두리 벽** 생성
* `for i in 1...3`
  → 3개의 경사진 \*\*플랫폼(plat)\*\*을 생성하고 물리 바디 설정

### 각 플랫폼 설정

* 회전각 `.pi / 8`, `-.pi / 8`을 사용해 경사 조절
* `categoryBitMask = 2`, `contactTestBitMask = 2`로 충돌 범주 설정
* `isDynamic = false`로 고정된 물체 (움직이지 않음)

---

## 2. **touchesBegan(\_:with:)**

* 사용자가 화면을 터치하면:

  * 반지름 5짜리 원형 공(`box`) 생성
  * 랜덤한 색상 적용
  * 해당 위치에 공 생성 후 중력 적용 (`affectedByGravity = true`)
  * category와 contact 비트마스크도 2번으로 설정 → 플랫폼과 충돌 감지 가능

---

## 3. **didBegin(\_:)**

* 공이 플랫폼에 닿을 때:

  * `platform1` → MIDI note 60
  * `platform2` → MIDI note 64
  * `platform3` → MIDI note 67
  * → 각각 다른 음을 재생 (도, 미, 솔)
* 그 외 바닥에 닿으면 `ball` 노드를 제거

---

## 4. **playSound(noteNumber:)**

* `MIDISampler`를 이용해 해당 note를 0.1초 동안 연주 후 중지

---

## 5. **SpriteKitAudioConductor**

* `MIDISampler`를 AudioKit에서 초기화
* `.exs` 사운드폰트 로딩 (e.g. sawPiano1.exs)
* `Reverb`로 출력 노드 감쌈 → 약간의 공간감 제공

---

## 6. **SpriteKitAudioView (SwiftUI)**

* `GameScene`을 SpriteView에 넣어 SwiftUI에서 표시
* `conductor`를 장면에 주입
* `.onAppear` / `.onDisappear`로 AudioKit 엔진 제어

---

## 🔊 동작 흐름 요약

1. 화면 터치 → 공 생성 → 중력에 의해 하강
2. 공이 플랫폼에 닿으면 → 해당 음 재생
3. 바닥에 닿으면 → 공 제거

---

# SpriteKit 부분 상세

`SpriteKit` 부분은 이 프로젝트에서 **그래픽과 물리 시뮬레이션을 담당**하며, 주로 `GameScene` 클래스 내에서 구성됩니다. 각 구성 요소를 더 구체적으로 설명드리겠습니다.

---

## 🧱 `GameScene` 구성 요소 상세

### 📍 `didMove(to:)`

SpriteKit 장면이 화면에 처음 표시될 때 호출되는 메서드입니다. 여기서 물리 월드 설정과 플랫폼 배치를 합니다.

#### 주요 구성:

  ```swift
  physicsWorld.contactDelegate = self
  ```

  → 물리 충돌 이벤트를 감지하기 위해 `SKPhysicsContactDelegate` 프로토콜을 채택하고, 해당 delegate를 자기 자신으로 지정합니다.

  ```swift
  physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
  ```

  → 화면 전체를 테두리로 감싸는 물리 벽 생성. 공이 밖으로 나가지 않도록 함.

  ```swift
  for i in 1...3 {
    ...
    addChild(plat)
  }
  ```

  → 경사진 3개의 플랫폼을 반복문으로 생성. 각 플랫폼은 `SKShapeNode`로 구성되고, 물리 바디가 설정됩니다.

#### 각 플랫폼의 설정:

```swift
plat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 10))
plat.physicsBody?.isDynamic = false
plat.physicsBody?.affectedByGravity = false
plat.physicsBody?.categoryBitMask = 2
plat.physicsBody?.contactTestBitMask = 2
```

* **isDynamic = false** → 위치가 고정되어 물리 반응은 있지만, 움직이지 않음
* **categoryBitMask & contactTestBitMask** → 충돌 감지 대상 설정 (같은 그룹끼리 감지 가능)

---

### 📍 `touchesBegan(_:with:)`

사용자가 화면을 터치하면 호출되는 메서드입니다.

* 원형 `SKShapeNode`(`box`)를 생성
* 터치 위치에 배치
* 중력 영향을 받도록 설정 (`affectedByGravity = true`)
* 충돌 감지를 위해 물리 바디 설정

예:

```swift
let box = SKShapeNode(circleOfRadius: 5)
box.physicsBody = SKPhysicsBody(circleOfRadius: 5)
box.physicsBody?.affectedByGravity = true
box.physicsBody?.categoryBitMask = 2
box.physicsBody?.contactTestBitMask = 2
```

이 공은 중력으로 낙하하며, platform과 category 설정이 같기 때문에 충돌 시 `didBegin(_:)` 호출됨.

---

### 📍 `didBegin(_ contact: SKPhysicsContact)`

SpriteKit의 충돌 이벤트가 발생했을 때 자동 호출되는 메서드입니다.

* `contact.bodyA`와 `contact.bodyB`를 통해 어떤 노드끼리 충돌했는지 확인
* 충돌한 platform이 어떤 것인지에 따라 다른 MIDI 노트(60, 64, 67)를 재생

또한, 특정 노드가 바닥이나 화면 하단에 닿은 경우 제거 처리도 여기에 포함될 수 있습니다.

---

## 🎯 SpriteKit에서 이 예제가 하는 일 요약

| 구성 요소                                   | 역할                  |
| --------------------------------------- | ------------------- |
| `SKScene`                               | 물리 공간 (게임 보드 같은 역할) |
| `SKPhysicsWorld`                        | 중력과 충돌 계산 수행        |
| `SKShapeNode`                           | 공 및 플랫폼 노드의 시각적 표현  |
| `SKPhysicsBody`                         | 실제 물리 연산을 담당하는 요소   |
| `categoryBitMask`, `contactTestBitMask` | 충돌 범주 정의 및 감지 설정    |
| `touchesBegan`                          | 공 생성 및 사용자 입력 반응    |
| `didBegin`                              | 충돌 시 사운드 재생 로직 실행   |

---


