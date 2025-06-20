//
//  SpriteKitAudio.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/11/25.
//

import SwiftUI
import SpriteKit
import AudioKit
import AVFoundation

#if os(iOS)
typealias PlatformColor = UIColor
#elseif os(macOS)
typealias PlatformColor = NSColor
#endif

// MARK: - SpriteKit

// SKPhysicsContactDelegate는 SpriteKit에서 물리적인 충돌 이벤트(접촉)를 처리할 수 있게 해주는 델리게이트(위임) 프로토콜입니다.
// “두 개의 물리 바디(SKNod)의 충돌을 감지해서, 무언가 반응하도록 만들고 싶을 때 사용하는 것”
class GameScene: SKScene, SKPhysicsContactDelegate {
  var conductor: SpriteKitAudioConductor?
  
  override func didMove(to view: SKView) {
    // SpriteKit의 **물리 세계(physicsWorld)**에 충돌 이벤트를 감지할 델리게이트를 등록하는 코드
    physicsWorld.contactDelegate = self
    // physicsBody = 공이나 물체가 화면 밖으로 빠져나가지 않도록 장면 전체를 둘러싸는 벽
    // edgeLoopFrom:는 모양은 있으나 질량이 없는 고정된 물리 바디
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    backgroundColor = .black
    
    for i in 1...3 {
      let plat = SKShapeNode(rectOf: CGSize(width: 80, height: 10))
      plat.fillColor = .gray
      plat.strokeColor = .gray
      
      if i == 2 {
        // 시계방향으로 22.43도 회전 => PI / 8 = 0.3925rad = 0.3925 / 0.0175 = 22.43도
        // 1도 = (PI / 180)rad = 0.0175rad
        plat.zRotation = .pi / 8
        plat.position = CGPoint(x: 590, y: 700 - 75 * i)
      } else {
        // 반시계방향으로 22.43도 회전
        plat.zRotation = -.pi / 8
        plat.position = CGPoint(x:490,y:700-75*i)
      }
      
      // SpriteKit의 물리 엔진에 의해 충돌 감지와 힘의 영향을 받는 대상
      plat.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 10))
      // 이 노드의 **충돌 그룹(범주)**을 2번 그룹으로 설정합니다.
      // 비트마스크를 사용하면 어떤 그룹끼리 충돌할 수 있는지 세밀하게 제어할 수 있습니다.
      plat.physicsBody?.categoryBitMask = 2
      // **충돌 감지를 원하는 그룹**을 설정합니다.
      // 여기서는 **2번 그룹과 접촉 시 `didBegin(_:)` 호출**을 원한다는 의미입니다.
      // 즉, 자기 자신이 속한 그룹(2번)과 충돌할 경우만 델리게이트가 반응합니다.
      plat.physicsBody?.contactTestBitMask = 2
      // 중력의 영향을 받지 않음, 플랫폼이 아래로 떨어지지 않고 고정된 위치에 유지됩니다.
      plat.physicsBody?.affectedByGravity = false
      // **물리적 반응 없음**: 충돌은 감지하지만 힘이나 충격에 의해 움직이지 않도록 함
      // 즉, 벽이나 바닥 같은 **고정 오브젝트 역할**을 하게 됩니다.
      plat.physicsBody?.isDynamic = false
      plat.name = "platform\(i)"
      addChild(plat)
    }
  }
  
  #if os(iOS)
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let location = touches.first?.location(in: self) else { return }
    spawnBall(at: location)
  }
  #elseif os(macOS)
  override func mouseDown(with event: NSEvent) {
    let location = event.location(in: self)
    spawnBall(at: location)
  }
  #endif
  
  func didBegin(_ contact: SKPhysicsContact) {
    if contact.nodesContainsName("platform1") {
      playSound(noteNumber: 60)
    } else if contact.nodesContainsName("platform2") {
      playSound(noteNumber: 64)
    } else if contact.nodesContainsName("platform3") {
      playSound(noteNumber: 67)
    }
    // 이 부분이 없다면 바닥에서 없어지지 않고 남아있음
    else if contact.bodyB.node?.name != "ball" || contact.bodyA.node?.name != "ball" {
      contact.bodyB.node?.removeFromParent()
    }
  }
  
  private func playSound(noteNumber: MIDINoteNumber) {
    guard let conductor else {
      return
    }
    
    conductor.instrument.play(noteNumber: noteNumber, velocity: 90, channel: 0)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      conductor.instrument.stop(noteNumber: noteNumber, channel: 0)
    }
  }
  
  private func spawnBall(at location: CGPoint) {
    let ball = SKShapeNode(circleOfRadius: 5)

    // 플랫폼 공통 색상 배열
    let colorList: [PlatformColor] = [
      .red, .green, .yellow, .orange, .magenta, .cyan,
      .systemOrange, .systemPink, .systemTeal, .systemMint
    ]

    ball.fillColor = colorList.randomElement()!
    ball.strokeColor = ball.fillColor
    // 터치 위치에 공 떨어트림
    ball.position = location
    // 물리적 충돌/중력 등 물리 시뮬레이션 대상 (화면에 보이지 않음)
    ball.physicsBody = SKPhysicsBody(circleOfRadius: 5)
    // 물리 바디에 **탄성 계수 (restitution)**를 설정: 충돌 시 반사(튕김) 정도
    // 0.0(전혀 튕김 없음) ~ 1.0(완전 탄성)
    ball.physicsBody?.restitution = 0.55
    ball.physicsBody?.categoryBitMask = 2
    ball.physicsBody?.contactTestBitMask = 2
    ball.physicsBody?.affectedByGravity = true
    ball.physicsBody?.isDynamic = true
    ball.name = "ball"
    addChild(ball)
  }
}

extension SKPhysicsContact {
  func nodesContainsName(_ name: String) -> Bool {
    self.bodyB.node?.name == name || self.bodyA.node?.name == name
  }
}

// MARK: - Audio Conductors

class SpriteKitAudioConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  @Published var instrument = MIDISampler(name: "Instrument 1")
  
  init() {
    engine.output = Reverb(instrument)
    
    do {
        if let fileURL = Bundle.main.url(forResource: "Sounds/Sampler Instruments/sawPiano1", withExtension: "exs") {
            try instrument.loadInstrument(url: fileURL)
        } else {
            Log("Could not find file")
        }
    } catch {
        Log("Could not load instrument")
    }
  }
}

// MARK: - Views

struct SpriteKitAudioView: View {
  @StateObject var conductor = SpriteKitAudioConductor()
  
  var scene: SKScene {
    let scene = GameScene()
    scene.size = CGSize(width: 1080, height: 1080)
    scene.scaleMode = .aspectFit
    scene.conductor = conductor
    scene.backgroundColor = .lightGray
    return scene
  }
  
  var body: some View {
    VStack {
      SpriteView(scene: scene)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  SpriteKitAudioView()
}
