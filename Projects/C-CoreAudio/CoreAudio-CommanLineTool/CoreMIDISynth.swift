//
//  CoreMIDISynth.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/17/25.
//

import Foundation
import AudioToolbox
import CoreMIDI

// MARK: - State struct

fileprivate struct MIDIPlayer {
  var graph: AUGraph?
  var instrumentUnit: AudioUnit?
}

// MARK: - Utility functions

fileprivate func setupAUGraph(_ player: inout MIDIPlayer) {
  checkError("Couldn't open AUGraph") {
    NewAUGraph(&player.graph)
  }
  
  // 출력 장치(스피커) 설명
  var outputCD = AudioComponentDescription()
  outputCD.componentType = kAudioUnitType_Output
  outputCD.componentSubType = kAudioUnitSubType_DefaultOutput
  outputCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  guard let graph = player.graph else {
    fatalError("ERROR: Graph is nil.")
  }
  
  // 위의 설명을 가지는 노드를 그래프에 추가
  var outputNode = AUNode.zero
  checkError("AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed") {
    AUGraphAddNode(
      graph,
      &outputCD,
      &outputNode
    )
  }
  
  var instrumentCD = AudioComponentDescription()
  instrumentCD.componentType = kAudioUnitType_MusicDevice
  instrumentCD.componentSubType = kAudioUnitSubType_DLSSynth
  instrumentCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  var instrumentNode = AUNode.zero
  checkError("AUGraphAddNode[kAudioUnitSubType_DLSSynth] failed") {
    AUGraphAddNode(
      graph,
      &instrumentCD,
      &instrumentNode
    )
  }
  
  // 그래프 열기 (자원 미할당)
  checkError("AUGraphOpen failed") {
    AUGraphOpen(graph)
  }
  
  // 악기 그래프 노드를 위해 AudioUnit 객체의 참조를 가짐
  checkError("AUGraphNodeInfo failed") {
    AUGraphNodeInfo(
      graph,
      instrumentNode,
      nil,
      &player.instrumentUnit
    )
  }
  
  // Synth AU의 출력을 출력 노드의 입력으로 연결
  checkError("AUGraphConnectNodeInput failed") {
    AUGraphConnectNodeInput(
      graph,
      instrumentNode,
      0,
      outputNode,
      0
    )
  }
  
  // 그래프 초기화 (자원 할당)
  checkError("AUGraphInitialize failed") {
    AUGraphInitialize(graph)
  }
}

fileprivate func setupMIDI(_ player: inout MIDIPlayer) {
  // MIDI Client Ref 생성
  var client: MIDIClientRef = .zero
  checkError("Couldn't create MIDI client") {
    MIDIClientCreate(
      "Core MIDI to System Sounds Demo" as CFString,
      CustomMIDINotifyProc,
      &player,
      &client
    )
  }
  
  // MIDI Port Ref 생성
  var inPort = MIDIPortRef.zero
  checkError("Couldn't create MIDI input port") {
    MIDIInputPortCreate(
      client,
      "Input port" as CFString,
      CustomMIDIReadProc,
      &player,
      &inPort
    )
  }
  
  // MIDI 포트를 가용한 소스에 연결
  let sourceCount: ULONG = MIDIGetNumberOfSources().toUInt32
  print("\(sourceCount) sources")
  
  for i in 0..<sourceCount {
    let src = MIDIGetSource(i.toInt)
    var _endpointName: Unmanaged<CFString>?
    checkError("Couldn't get endpoint name") {
      MIDIObjectGetStringProperty(
        src,
        kMIDIPropertyName,
        &_endpointName
      )
    }
    
    guard let endpointName = _endpointName?.takeRetainedValue() else {
      fatalError("ERROR: endpointName is nil.")
    }
    
    print("source \(i): \(endpointName)")
    
    checkError("Couldn't connect MIDI port") {
      MIDIPortConnectSource(
        inPort,
        src,
        nil
      )
    }
  }
}

// MARK: - Callbacks

func CustomMIDINotifyProc(
  _ message: UnsafePointer<MIDINotification>,
  _ refCon: UnsafeMutableRawPointer?
) {
  print("MIDI Notify, messageID: \(message.pointee.messageID)")
}

func CustomMIDIReadProc(
  _ pktlist: UnsafePointer<MIDIPacketList>,
  _ readProcRefCon: UnsafeMutableRawPointer?,
  _ srcConnRefCon: UnsafeMutableRawPointer?
) {
  guard let readProcRefCon else {
    fatalError("ERROR: readProcRefCon should not be nil in CustomMIDIReadProc.")
  }
  
  let playerPtr = readProcRefCon.assumingMemoryBound(to: MIDIPlayer.self)
  var midiPacket: MIDIPacket = pktlist.pointee.packet
  
  for _ in 0..<pktlist.pointee.numPackets {
    let midiStatus: UInt8 = midiPacket.data.0
    // 상태를 오른쪽으로 4비트 이동하여 명령어를 얻고,
    let midiCommand: UInt8 = midiStatus >> 4
    // 그 명령어가 note on/off 인지 확인한다.
    if midiCommand == 0x08 || midiCommand == 0x09 {
      /*
       •  MIDI 패킷의 **두 번째 바이트(1번 인덱스)**에서 노트 번호를 추출하는 코드입니다.
       •  midiPacket.data.1은 MIDI 메시지에서 **노트 번호(어떤 음을 연주하는지)**를 포함하고 있습니다.
       •  & 0x7f 연산은 하위 7비트(0~127)만 추출하는 역할을 합니다.
       •  MIDI 데이터는 상위 1비트를 status bit로 사용하므로, & 0x7f 연산을 통해 상위 1비트를 제거하고 실제 노트 값을 가져옵니다.
       •  MIDI의 노트 번호는 **0~127(총 128개 음)**의 범위를 가집니다.
       */
      let note: UInt8 = midiPacket.data.1 & 0x7f
      // 동일한 구조의 velocity를 추출
      let velocity: UInt8 = midiPacket.data.2 & 0x7f
      
      // MIDI 이벤트를 장치 유닛으로 전송
      checkError("Couldn't send MIDI event") {
        MusicDeviceMIDIEvent(
          playerPtr.pointee.instrumentUnit!,
          UInt32(midiStatus),
          UInt32(note),
          UInt32(velocity),
          0
        )
      }
      
      print("midiStatus = \(midiStatus), note = \(note), velocity = \(velocity)")
      
      // 다음 패킷으로 이동
      midiPacket = MIDIPacketNext(&midiPacket).pointee
    }
  }
}

// MARK: - Main

func CoreMIDISynth_main() {
  var player: MIDIPlayer = .init()
  
  setupAUGraph(&player)
  setupMIDI(&player)
  
  guard let graph = player.graph else {
    fatalError("Failed to create AUGraph")
  }
  
  checkError("Couldn't start graph") {
    AUGraphStart(graph)
  }
  
  CFRunLoopRun()  // ctrl+C 로 중지될때까지 실행
}
