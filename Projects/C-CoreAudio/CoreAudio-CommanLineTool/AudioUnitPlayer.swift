//
//  AudioUnitPlayer.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/5/25.
//

/*
 ┌───────────┐        ┌──────────────┐
 │AUAudio    ├───────►│ Basic Output ├──────► Hardware...
 │FilePlayer │        │   Unit       │
 └───────────┘        └──────────────┘
 */

import Foundation
import AudioToolbox

// MARK: - User Data Struct

fileprivate struct AUGraphPlayer {
  var inputFormat = AudioStreamBasicDescription()
  var inputFileID: AudioFileID?
  var graph: AUGraph?
  var fileAU: AudioUnit?
}

// MARK: - Utility Functions

// CheckError(): 분리

fileprivate func createAUGraph(_ player: inout AUGraphPlayer) {
  // 새로운 AUGraph를 생성
  checkError("NewAUGraph failed") {
    NewAUGraph(&player.graph)
  }
  
  // 출력 장치(스피커)에 일치하는 description 생성
  var outputCD = AudioComponentDescription()
  outputCD.componentType = kAudioUnitType_Output
  outputCD.componentSubType = kAudioUnitSubType_DefaultOutput
  outputCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  guard let playerGraph = player.graph else {
    print("ERROR: PlayerGraph is nil.")
    exit(1)
  }
  
  // 그래프에 위의 outputCD에 대한 노드 outputNode를 추가
  var outputNode = AUNode()
  checkError("AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed") {
    AUGraphAddNode(
      playerGraph,
      &outputCD,
      &outputNode
    )
  }
  
  // 오디오파일 재생기 형식의 생성기 AU에 일치하는 description 생성
  var filePlayerCD = AudioComponentDescription()
  filePlayerCD.componentType = kAudioUnitType_Generator
  filePlayerCD.componentSubType = kAudioUnitSubType_AudioFilePlayer
  filePlayerCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  // 그래프에 위의 filePlayerCD에 대한 노드 fileNode를 추가
  var fileNode = AUNode()
  checkError("AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed") {
    AUGraphAddNode(
      playerGraph,
      &filePlayerCD,
      &fileNode
    )
  }
  
  // AUGraph 열기
  // 그래프를 여는 것은 모든 포함된 오디오 유닛을 열지만, 아무런 자원을 할당하지 않는다
  checkError("AUGraphOpen failed") {
    AUGraphOpen(player.graph!)
  }
  
  // AUNode에서 AudioUnit을 추출
  // 파일 재생기 그래프 노드를 위한 AudioUnit 객체의 참조를 획득
  checkError("AUGraphNodeInfo failed") {
    AUGraphNodeInfo(
      playerGraph,
      fileNode,
      nil,
      &player.fileAU
    )
  }
  
  // AUGraph에서 노드 연결: 파일 재생기 AU의 출력을 출력 노드의 입력으로 연결
  checkError("AUGraphConnectNodeInput") {
    AUGraphConnectNodeInput(
      playerGraph, // inGraph: AUGraph,
      fileNode, // inSourceNode: AUNode, (소스 노드)
      0, // inSourceOutputNumber: UInt32, (소스 출력 번호)
      outputNode, // _ inDestNode: AUNode, (목적지 노드)
      0 // _ inDestInputNumber: UInt32 (목적지 출력 번호)
    )
  }
  
  /*
   혼합기 유닛으로 두 개의 버스를 하나로 통합
   - Bus 0: 장치 출력
   - Bus 1: 장치 입력
   
                      Bus 1 ->
     [임의의 2채널 유닛]            [AUStereo 혼합기] -> Bus 0
                      Bus 0 ->
   */
  
  // AUGraph 초기화: 자원이 할당되도록 함
  checkError("AUGraphInitialize failed") {
    AUGraphInitialize(playerGraph)
  }
}

fileprivate func prepareFileAU(_ player: inout AUGraphPlayer) -> Float64 {
  // AUFilePlayer로 AudioFileID를 계획
  // 파일 재생기 유닛에게 재생을 원하는 파일을 불러오도록 명령
  
  guard let playerFileAU = player.fileAU else {
    print("ERROR: PlayerFileAU is nil.")
    exit(1)
  }
  
  checkError("AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed") {
    AudioUnitSetProperty(
      playerFileAU,
      kAudioUnitProperty_ScheduledFileIDs,
      kAudioUnitScope_Global, // inScope: AudioUnitScope, (속성이 AU의 어떤 부분에 적용되는지)
      0, // inElement: AudioUnitElement (파일 ID 속성에서 엘리먼트/버스는 의미가 없다)
      &player.inputFileID,
      MemoryLayout.size(ofValue: player.inputFileID).toUInt32
    )
  }
  
  // AUFilePlayer를 위한 ScheduledAudioFileRegion 설정
  var nPackets: UInt64 = 0
  var propSize: UInt32 = MemoryLayout.size(ofValue: nPackets).toUInt32
  checkError("AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount] failed") {
    AudioFileGetProperty(
      player.inputFileID!,
      kAudioFilePropertyAudioDataPacketCount,
      &propSize,
      &nPackets
    )
  }
  
  // 파일 재생기 AU에 전체 파일을 재생하라고 명령한다
  var region = ScheduledAudioFileRegion(
    mTimeStamp: AudioTimeStamp(),
    mCompletionProc: nil,
    mCompletionProcUserData: nil,
    mAudioFile: player.inputFileID!,
    mLoopCount: 1,
    mStartFrame: 0,
    mFramesToPlay: UInt32(nPackets) * player.inputFormat.mFramesPerPacket
  )
  
  region.mTimeStamp.mFlags = .sampleTimeValid
  region.mTimeStamp.mSampleTime = 0
  
  checkError("AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed.") {
    AudioUnitSetProperty(
      playerFileAU,
      kAudioUnitProperty_ScheduledFileRegion,
      kAudioUnitScope_Global,
      0, // inElement:
      &region,
      MemoryLayout.size(ofValue: region).toUInt32
    )
  }
  
  // AUFilePlayer를 위해 계획된 시작 시간 설정
  // 파일 재생기 AU에 언제 재생을 시작할지 알려줌
  // (샘플 시간 -1 은 다음 렌더 사이클을 의미)
  var startTime = AudioTimeStamp()
  startTime.mFlags = .sampleTimeValid
  startTime.mSampleTime = -1
  
  checkError("AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp] failed") {
    AudioUnitSetProperty(
      playerFileAU,
      kAudioUnitProperty_ScheduleStartTimeStamp,
      kAudioUnitScope_Global,
      0,
      &startTime,
      MemoryLayout.size(ofValue: startTime).toUInt32
    )
  }
  
  // 파일 재생 시간을 초로 계산
  let totalFrames = Float64(nPackets * UInt64(player.inputFormat.mFramesPerPacket))
  return totalFrames / player.inputFormat.mSampleRate
}

// MARK: - Main

func AudioUnitPlayer_main() {
  var player = AUGraphPlayer()
  
  print("[AudiUnitPlayer] 재생할 오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 오디오 파일 열기
  let inputFileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(inputFileURL.absoluteString)
  
  checkError("AudioFileOpenURL failed") {
    AudioFileOpenURL(
      inputFileURL as CFURL,
      .readPermission,
      0,
      &player.inputFileID
    )
  }
  
  // 파일에서 오디오 데이터 형식을 얻음
  var propSize: UInt32 = MemoryLayout.size(ofValue: player.inputFormat).toUInt32
  checkError("Couldn't get file's data format") {
    AudioFileGetProperty(
      player.inputFileID!,
      kAudioFilePropertyDataFormat,
      &propSize,
      &player.inputFormat
    )
  }
  
  // 기본적인 파일 재생기 -> 스피커 그래프를 생성
  createAUGraph(&player)
  
  // 파일 재생기를 설정
  let fileDuration: Float64 = prepareFileAU(&player)
  
  checkError("AUGraphStart failed") {
    AUGraphStart(player.graph!)
  }
  
  // 파일이 종료될 때까지 수면모드로 유지
  usleep(useconds_t(fileDuration * 1000.0 * 1000.0))
  
  // AUgraph를 종료하고 해제하기
  do {
    AUGraphStop(player.graph!)
    AUGraphUninitialize(player.graph!)
    AUGraphClose(player.graph!)
    AudioFileClose(player.inputFileID!)
  }
}
