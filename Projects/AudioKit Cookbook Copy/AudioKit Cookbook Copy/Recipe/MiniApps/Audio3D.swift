//
//  Audio3D.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/29/25.
//

import SwiftUI
import Combine
import AudioKit
import AudioKitUI
import AudioToolbox
import Keyboard
import SoundpipeAudioKit
import Tonic
import SceneKit
import AVFoundation

@Observable
final class AudioKit3DViewModel {
  var conductor = AudioEngine3DConductor()
  var coordinator = SceneCoordinator()
  
  init() {
    coordinator.updateAudioSourceNodeDelegate = conductor
  }
}

//  AnyObject: 그 프로토콜이 클래스에서만 채택되도록 제한하고 싶을 때
protocol UpdateAudioSourceNodeDelegate: AnyObject {
  func updateListenerPosition3D(_ position: AVAudio3DPoint)
  func updateListenerOrientationVector(_ vector: AVAudio3DVectorOrientation)
  func updateListenerOrientationAngular(_ angular: AVAudio3DAngularOrientation)
  func updateSoundSourcePosition(_ position3D: AVAudio3DPoint)
}

class AudioEngine3DConductor: ProcessesPlayerInput, UpdateAudioSourceNodeDelegate {
  let engine = AudioEngine()
  var player = AudioPlayer()
  let buffer: AVAudioPCMBuffer
  
  var source1Mixer3D = Mixer3D(name: "AudioPlayer Mixer")
  var environmentalNode = EnvironmentalNode()
  
  init() {
    buffer = Cookbook.sourceBuffer
    player.buffer = buffer
    player.isLooping = true
    
    // Always connect the sound you want to position to a Mixer3D
    // Then connect the Mixer3D to the EnvironmentalNode
    source1Mixer3D.addInput(player)
    
    // Not all these parameters are always neededs
    // Just here for example
    source1Mixer3D.pointSourceInHeadMode = .mono
    environmentalNode.renderingAlgorithm = .auto
    environmentalNode.reverbParameters.loadFactoryReverbPreset(.largeHall2)
    environmentalNode.connect(mixer3D: source1Mixer3D)
    environmentalNode.outputType = .externalSpeakers
    
    engine.output = environmentalNode
    engine.mainMixerNode?.pan = 1.0
    
    Log(engine.avEngine)
  }
  
  deinit {
    player.stop()
    engine.stop()
  }
  
  func updateListenerPosition3D(_ position: AVAudio3DPoint) {
    environmentalNode.listenerPosition = position
  }
  
  func updateListenerOrientationVector(_ vector: AVAudio3DVectorOrientation) {
    environmentalNode.listenerVectorOrientation = AVAudio3DVectorOrientation(
      forward: vector.forward,
      up: vector.up
    )
  }
  
  func updateListenerOrientationAngular(_ angular: AVAudio3DAngularOrientation) {
    // Not using
  }
  
  func updateSoundSourcePosition(_ position3D: AVAudio3DPoint) {
    source1Mixer3D.position = position3D
  }
}

class SceneCoordinator: NSObject, SCNSceneRendererDelegate {
  var showStatistics: Bool = false
  var debugOptions: SCNDebugOptions = []
  
  weak var updateAudioSourceNodeDelegate: UpdateAudioSourceNodeDelegate?
  
  lazy var theScene: SCNScene = {
    SCNScene(named: "audio3D.scnassets/audio3DTest.scn")!
  }()
  
  var cameraNode: SCNNode? {
    let cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.position = SCNVector3(x: 0, y: 1, z: 0)
    return cameraNode
  }
  
  func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if let pointOfView = renderer.pointOfView,
       let soundSource = renderer.scene?.rootNode.childNode(
        withName: "soundSource",
        recursively: true
       ) {
      
      updateAudioSourceNodeDelegate?.updateSoundSourcePosition(
        AVAudio3DPoint(
          x: soundSource.position.x,
          y: soundSource.position.y,
          z: soundSource.position.z
        )
      )
      
      // Make sure you update the Listener Position
      // and Oriental (either by Vector of Angular) together
      updateAudioSourceNodeDelegate?.updateListenerPosition3D(
        AVAudio3DPoint(
          x: pointOfView.position.x,
          y: pointOfView.position.y,
          z: pointOfView.position.z
        )
      )
      
      updateAudioSourceNodeDelegate?.updateListenerOrientationVector(
        AVAudio3DVectorOrientation(
          forward: AVAudio3DVector(
            x: pointOfView.forwardVector.x,
            y: pointOfView.forwardVector.y,
            z: pointOfView.forwardVector.z
          ),
          up: AVAudio3DVector(
            x: pointOfView.upVector.x,
            y: pointOfView.upVector.y,
            z: pointOfView.upVector.z
          )
        )
      )
      
      renderer.showsStatistics = showStatistics
      renderer.debugOptions = debugOptions
    }
  }
}

struct AudioKit3DView: View {
  private var viewModel = AudioKit3DViewModel()
  
  var body: some View {
    VStack {
      // 소스 선택기: conductor의 buffer에 저장
      PlayerControls(conductor: viewModel.conductor)
      HStack {
        ForEach(viewModel.conductor.player.parameters) {
          ParameterRow(param: $0)
        }
      }
      .padding(5)
      .frame(width: 600, height: 100, alignment: .center)
      
      Spacer()
      
      VStack {
        SceneView(
          scene: viewModel.coordinator.theScene,
          pointOfView: viewModel.coordinator.cameraNode,
          options: [.allowsCameraControl],
          delegate: viewModel.coordinator
        )
      }
      .frame(
        minWidth: 0,
        maxWidth: .infinity,
        minHeight: 0,
        maxHeight: .infinity,
        alignment: .center
      )
      
      Spacer()
    }
    .navigationTitle("Audio 3D")
    .onAppear {
      viewModel.conductor.start()
    }
    .onDisappear {
      viewModel.conductor.stop()
    }
  }
}

#Preview {
  AudioKit3DView()
}
