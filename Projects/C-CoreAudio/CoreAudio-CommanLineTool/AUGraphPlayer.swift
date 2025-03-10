//
//  AUGraphPlayer.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/10/25.
//

import Foundation
import AudioToolbox

// MARK: - User Data Struct

fileprivate struct AUGraphPlayer {
  var streamFormat: AudioStreamBasicDescription?
  var graph: AUGraph?
  var inputUnit: AudioUnit?
  var outputUnit: AudioUnit?
  
  // ifdef: Part 2
  
  var inputBufferList: UnsafeMutablePointer<AudioBufferList>?
  var ringBuffer: UnsafeMutablePointer<CARingBufferWrapper>?
  
  var firstInputSampleTime: Float64 = 0
  var firstOutputSampleTime: Float64 = 0
  var inToOutSampleTimeOffset: Float64 = 0
}

// MARK: - Render Procs

fileprivate func InputRenderProc(
  inRefCon: UnsafeMutableRawPointer,
  ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp: UnsafePointer<AudioTimeStamp>,
  inBusNumber: UInt32,
  inNumberFrames: UInt32,
  ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
  let playerPtr = inRefCon.assumingMemoryBound(to: AUGraphPlayer.self)
  
  // 입력 시간을 로그로 남긴 적이 있는가? (오프셋 계산을 위해서)
  if playerPtr.pointee.firstInputSampleTime < 0 {
    playerPtr.pointee.firstInputSampleTime = inTimeStamp.pointee.mSampleTime
    
    if playerPtr.pointee.firstInputSampleTime > -1 && playerPtr.pointee.inToOutSampleTimeOffset < 0 {
      playerPtr.pointee.inToOutSampleTimeOffset = playerPtr.pointee.firstInputSampleTime - playerPtr.pointee.firstOutputSampleTime
    }
  }
  
  // 입력 AUHAL에서 캡처된 샘플 추출
  var inputProcErr = AudioUnitRender(
    playerPtr.pointee.inputUnit!,
    ioActionFlags,
    inTimeStamp,
    inBusNumber,
    inNumberFrames,
    playerPtr.pointee.inputBufferList!
  )
  
  // 캡처된 샘플을 CARingBuffer에 저장
  if inputProcErr == noErr {
    let result = playerPtr.pointee.ringBuffer!.pointee.store(
      playerPtr.pointee.inputBufferList!,
      nFrames: inNumberFrames,
      frameNumber: Int64(inTimeStamp.pointee.mSampleTime)
    )
    
    inputProcErr = result ? noErr : -1
  }
  
  return inputProcErr
}

fileprivate func GraphRenderProc(
  inRefCon: UnsafeMutableRawPointer,
  ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp: UnsafePointer<AudioTimeStamp>,
  inBusNumber: UInt32,
  inNumberFrames: UInt32,
  ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
  let playerPtr = inRefCon.assumingMemoryBound(to: AUGraphPlayer.self)
  
  // 시간을 기록한 적이 있는가? (오프셋 계산을 위해)
  if playerPtr.pointee.firstOutputSampleTime < 0 {
    playerPtr.pointee.firstOutputSampleTime = inTimeStamp.pointee.mSampleTime
    
    if playerPtr.pointee.firstInputSampleTime > -1 && playerPtr.pointee.inToOutSampleTimeOffset < 0 {
      playerPtr.pointee.inToOutSampleTimeOffset = playerPtr.pointee.firstInputSampleTime - playerPtr.pointee.firstOutputSampleTime
    }
  }
  
  let result = playerPtr.pointee.ringBuffer!.pointee.fetch(
    ioData!,
    nFrames: inNumberFrames,
    frameNumber: Int64(inTimeStamp.pointee.mSampleTime + playerPtr.pointee.inToOutSampleTimeOffset)
  )
  
  return result ? noErr : -1
}

// MARK: - Utility Functions

fileprivate func createInputUnit(_ player: inout AUGraphPlayer) {
  // 오디오 HAL(Hardware Abstration Layer) 에 일치하는 설명 생성
  var inputCD = AudioComponentDescription()
  inputCD.componentType = kAudioUnitType_Output
  inputCD.componentSubType = kAudioUnitSubType_HALOutput
  inputCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  guard let comp = AudioComponentFindNext(nil, &inputCD) else {
    fatalError("ERROR: comp is nil.")
  }
  
  checkError("Couldn't open component for input unit") {
    AudioComponentInstanceNew(comp, &player.inputUnit)
  }
  
  // 입력 AUHAL의 IO 활성화
  var disableFlag: UInt32 = 0
  var enableFlag: UInt32 = 1
  let outputBus: AudioUnitScope = 0
  let inputBus: AudioUnitElement = 1
  
  guard let inputUnitPtr = player.inputUnit else {
    fatalError("ERROR: inputUnitPtr is nil.")
  }
  
  checkError("Couldn't enable input on I/O unit") {
    AudioUnitSetProperty(
      inputUnitPtr,
      kAudioOutputUnitProperty_EnableIO,
      kAudioUnitScope_Input,
      inputBus,
      &enableFlag,
      MemoryLayout.size(ofValue: enableFlag).toUInt32
    )
  }
  
  checkError("Couldn't disable output on I/O unit") {
    AudioUnitSetProperty(
      inputUnitPtr,
      kAudioOutputUnitProperty_EnableIO,
      kAudioUnitScope_Output,
      outputBus,
      &disableFlag,
      MemoryLayout.size(ofValue: disableFlag).toUInt32
    )
  }
  
  // 기본 오디오 입력 장치 획득
  var defaultDeviceID: AudioDeviceID = kAudioObjectUnknown
  var propSize: UInt32 = MemoryLayout.size(ofValue: defaultDeviceID).toUInt32
  var defaultDevicePropertyAddress = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultInputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  
  checkError("Couldn't get default input device") {
    AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &defaultDevicePropertyAddress,
      0,
      nil,
      &propSize,
      &defaultDeviceID
    )
  }
  
  guard let inputUnitPtr = player.inputUnit else {
    fatalError("ERROR: inputUnit is nil.")
  }
  
  // AUHAL의 현재 장치 속성 설정
  checkError("Couldn't set default device on I/O unit") {
    AudioUnitSetProperty(
      inputUnitPtr,
      kAudioOutputUnitProperty_CurrentDevice,
      kAudioUnitScope_Global,
      outputBus,
      &defaultDeviceID,
      MemoryLayout.size(ofValue: defaultDeviceID).toUInt32
    )
  }
  
  // 입력 AUHAL에서 ASBD 획득
  propSize = MemoryLayout<AudioStreamBasicDescription>.size.toUInt32
  checkError("\(#line): Couldn't get ASBD from input unit") {
    AudioUnitGetProperty(
      inputUnitPtr,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Output,
      inputBus,
      &player.streamFormat,
      &propSize
    )
  }
  
  // 하드웨어 입력 샘플율 수용
  var deviceFormat = AudioStreamBasicDescription()
  checkError("\(#line): Couldn't get ASBD from input unit") {
    AudioUnitGetProperty(
      inputUnitPtr,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Input,
      inputBus,
      &deviceFormat,
      &propSize
    )
  }
  
  player.streamFormat!.mSampleRate = deviceFormat.mSampleRate
  propSize = MemoryLayout<AudioStreamBasicDescription>.size.toUInt32
  checkError("\(#line): Couldn't set ASBD on input unit") {
    AudioUnitSetProperty(
      inputUnitPtr,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Output,
      inputBus,
      &player.streamFormat,
      propSize
    )
  }
  
  // IO 유닛을 위한 캡처 버퍼 크기 계산
  var bufferSizeFrames: UInt32 = 0
  propSize = MemoryLayout<UInt32>.size.toUInt32
  checkError("Couldn't get buffer frame size from input unit") {
    AudioUnitGetProperty(
      inputUnitPtr,
      kAudioDevicePropertyBufferFrameSize,
      kAudioUnitScope_Global,
      0,
      &bufferSizeFrames,
      &propSize
    )
  }
  
  let bufferSizeBytes = bufferSizeFrames * MemoryLayout<Float32>.size.toUInt32
  
  // 캡처 데이터를 수신하기 위해 AudioBufferList를 생성
  // AudioBuffers 배열을 위한 AudioBufferList와 충분한 공간 할당
  let offset = MemoryLayout<AudioBufferList>.offset(of: \AudioBufferList.mBuffers)!
  let audioBufferSize = MemoryLayout<AudioBuffer>.size.toUInt32 * player.streamFormat!.mChannelsPerFrame
  let bufferListSize = offset + audioBufferSize.toInt
  
  // 버퍼 목록 메모리 할당
  player.inputBufferList = .allocate(capacity: bufferListSize)
  player.inputBufferList!.pointee = AudioBufferList()
  player.inputBufferList!.pointee.mNumberBuffers = player.streamFormat!.mChannelsPerFrame
  
  // AudioBufferLists 의 버퍼를 위해 미리 메모리 할당
  for i in 0..<Int(player.inputBufferList!.pointee.mNumberBuffers) {
    player.inputBufferList!.pointee.mBuffers.mNumberChannels = i.toUInt32
    player.inputBufferList!.pointee.mBuffers.mDataByteSize = bufferSizeBytes
    player.inputBufferList!.pointee.mBuffers.mData = UnsafeMutableRawPointer.allocate(
      byteCount: bufferSizeBytes.toInt,
      alignment: MemoryLayout<UInt8>.size
    )
  }
  
  // CARingBuffer 생성: 두 개의 오디오 장치 사이에 데이터를 저장할 링 버퍼를 할당
  player.ringBuffer = .allocate(capacity: MemoryLayout<CARingBufferWrapper>.size)
  player.ringBuffer!.pointee = CARingBufferWrapper(
    channels: Int32(player.streamFormat!.mChannelsPerFrame),
    bytesPerFrame: player.streamFormat!.mBytesPerFrame,
    capacityFrames: bufferSizeFrames * 3
  )
  
  // AUHAL에 입력 콜백 설정
  // 입력 유닛에서 샘플을 제공하기 위해 렌더 프로세스를 설정
  var callbackStruct = AURenderCallbackStruct()
  callbackStruct.inputProc = InputRenderProc
  withUnsafeMutablePointer(to: &player) { pointer in
    callbackStruct.inputProcRefCon = UnsafeMutableRawPointer(pointer)
  }
  
  // 입력 AUHAL과 오프셋 타임 카운터 초기화
  checkError("Couldn't initialize input unit") {
    AudioUnitInitialize(inputUnitPtr)
  }
  
  player.firstInputSampleTime = -1
  player.inToOutSampleTimeOffset = -1
  
  print("Bottom of CreateInput()")
}

fileprivate func createAUGraph(_ player: inout AUGraphPlayer) {
  // 새로운 AUGraph 생성
  checkError("NewAUGraph failed") {
    NewAUGraph(&player.graph)
  }
  
  // 기본 출력에 일치하는 설명 생성
  var outputCD = AudioComponentDescription()
  outputCD.componentType = kAudioUnitType_Output
  outputCD.componentSubType = kAudioUnitSubType_DefaultOutput
  outputCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  guard let comp = AudioComponentFindNext(nil, &outputCD) else {
    fatalError("ERROR: Can't get output unit.")
  }
  
  checkError("Couldn't open component for outputUnit unit") {
    AudioComponentInstanceNew(comp, &player.outputUnit)
  }
  
  guard let playerGraph = player.graph else {
    fatalError("ERROR: playerGraph is nil.")
  }
  
  // 그래프에 노드를 추가
  var outputNode = AUNode()
  checkError("AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed") {
    AUGraphAddNode(
      playerGraph,
      &outputCD,
      &outputNode
    )
  }
  
  // ifdef: Part 2
  
  // AUGraph 열기
  // 그래프를 여는 것은 모든 포함된 오디오 유닛을 열지만, 아무런 자원을 할당하지 않는다
  checkError("AUGraphOpen failed") {
    AUGraphOpen(playerGraph)
  }
  
  // AUNode에서 AudioUnit을 추출
  // 출력 그래프 노드를 위한 AudioUnit 객체의 참조를 획득
  checkError("AUGraphNodeInfo failed") {
    AUGraphNodeInfo(
      playerGraph,
      outputNode,
      nil,
      &player.outputUnit
    )
  }
  
  guard let outputUnitPtr = player.outputUnit else {
    fatalError("ERROR: outputUnit is nil.")
  }
  
  // 출력 유닛의 입력 스코프에 스트림 설정
  let propSize: UInt32 = MemoryLayout<AudioStreamBasicDescription>.size.toUInt32
  checkError("Couldn't set stream format on output unit") {
    AudioUnitSetProperty(
      outputUnitPtr,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Input,
      0,
      &player.streamFormat,
      propSize
    )
  }
  
  var callbackStruct = AURenderCallbackStruct()
  callbackStruct.inputProc = GraphRenderProc
  withUnsafeMutablePointer(to: &player) { pointer in
    callbackStruct.inputProcRefCon = UnsafeMutableRawPointer(pointer)
  }
  
  checkError("Couldn't set render callback on output unit") {
    AudioUnitSetProperty(
      outputUnitPtr,
      kAudioUnitProperty_SetRenderCallback,
      kAudioUnitScope_Global,
      0,
      &callbackStruct,
      MemoryLayout.size(ofValue: callbackStruct).toUInt32
    )
  }
  
  // 그래프 초기화 (자원이 할당됨)
  checkError("AUGraphInitialize failed") {
    AUGraphInitialize(playerGraph)
  }
  
  // 콜백이 처음 호출되었을때로 원복
  player.firstOutputSampleTime = -1
}

// MARK: - Main

func AUGraphPlayer_main() {
  var player = AUGraphPlayer()
  
  // 입력 유닛 생성
  player.streamFormat = AudioStreamBasicDescription()
  
  createInputUnit(&player)
  
  // 출력 유닛을 그래프로 만들기
  createAUGraph(&player)
  
  // ifdef: PART 2
  
  guard let inputUnitPointer = player.inputUnit,
        let graphPointer = player.graph else {
    fatalError("inputUnitPointer is nil")
  }
  
  // 재생 시작
  checkError("AudioOutputUnitStart failed") {
    AudioOutputUnitStart(inputUnitPointer)
  }
  checkError("AUGrpahStart failed") {
    AUGraphStart(graphPointer)
  }
  
  print("Capturing... press <return> to stop:", terminator: " ")
  _ = readLine()
  
  do {
    AUGraphStop(graphPointer)
    AUGraphUninitialize(graphPointer)
    AUGraphClose(graphPointer)
  }
}
