//
//  AudioUnitSineWave.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/6/25.
//

import Foundation
import AudioToolbox

fileprivate let SINE_FREQ: Double = 880.0

/*
       렌더 콜백 함수 -> [기본 출력 유닛] -> 하드웨어
 */

// MARK: - User Data Struct

fileprivate struct SineWavePlayer {
  var outputAU: AudioUnit?
  var startingFrameCount: Double = 0.0
}

// MARK: - Utility Functions

// CheckError(): 분리

fileprivate func createAndConnectOutput(_ player: inout SineWavePlayer) {
  // 기본 출력 오디오 유닛 Desc
  var outputCD = AudioComponentDescription()
  outputCD.componentType = kAudioUnitType_Output
  outputCD.componentSubType = kAudioUnitSubType_DefaultOutput
  outputCD.componentManufacturer = kAudioUnitManufacturer_Apple
  
  // AudioComponentFindNext로 오디오 유닛 획득
  guard let component = AudioComponentFindNext(nil, &outputCD) else {
    fatalError("ERROR: Can't get output unit.")
  }
  
  checkError("Couldn't open component for outputUnit") {
    AudioComponentInstanceNew(
      component,
      &player.outputAU
    )
  }
  
  // 렌더 콜백 등록
  var input = AURenderCallbackStruct()
  input.inputProc = SineWaveRenderProc
  
  // input.inputProcRefCon(<= UnsafeMutableRawPointer?) = player;
  withUnsafeMutablePointer(to: &player) { pointer in
    input.inputProcRefCon = UnsafeMutableRawPointer(pointer)
  }
  
  checkError("AudioUnitSetProperty failed") {
    AudioUnitSetProperty(
      player.outputAU!,
      kAudioUnitProperty_SetRenderCallback,
      kAudioUnitScope_Input,
      0,
      &input,
      MemoryLayout.size(ofValue: input).toUInt32
    )
  }
  
  // 유닛 초기화
  checkError("Couldn't initialize output unit") {
    AudioUnitInitialize(player.outputAU!)
  }
}

/**
 AURenderCallback을 따르고, Sine 파형을 만든다.

 - Parameters:
    - inRefCon: 컨텍스트(사용자 정보) 포인터
    - ioAcitonFlags: 호출의 목적을 나타내는 비트 필드, 보통 0
    - inTimeStamp: 다른 호출이 렌더 콜백을 호출하는 시점의 상대적 타이밍
    - inBusNumber: AU의 어떤 버스가 오디오 데이터를 요청하는지
    - inNumberFrames: 렌더링 될 프레임 수. 콜백은 정확하게 요청된 수의 프레임만 제공해야 함
    - ioData: 데이터로 채워진 AudioBufferList 구조체
 - Returns: OSStatus (성공 시 `noErr`)
 */
fileprivate func SineWaveRenderProc(
  inRefCon: UnsafeMutableRawPointer,
  ioAcitonFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
  inTimeStamp: UnsafePointer<AudioTimeStamp>,
  inBusNumber: UInt32,
  inNumberFrames: UInt32,
  ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
  print(String(format: "[SineWaveProc] needs %ld frames at %f", inNumberFrames, CFAbsoluteTimeGetCurrent()))
  let playerPointer = inRefCon.assumingMemoryBound(to: SineWavePlayer.self)
  let player = playerPointer.pointee
  
  /// 프레임 수로 측정되는 파형의 오프셋 (또는 위상)을 나타내는 지역 변수
  var j: Double = player.startingFrameCount
  /// 사이클 길이(또는 파장) 설정
  let cycleLength: Double = 44100.0 / SINE_FREQ
  
  for frame in 0..<inNumberFrames {
    ioData!.pointee.mBuffers.mNumberChannels = 1 // 채널 번호 변경 방법
    var data = ioData!.pointee.mBuffers.mData!.assumingMemoryBound(to: Float32.self)
    
    // (data) [frame] = (Float32) sin( 2* M_PI * (j / cycleLength);
    data[frame.toInt] = Float32( sin( 2 * .pi * (j / cycleLength) ) )
    
    // 적절한 채널로 복사
    ioData!.pointee.mBuffers.mNumberChannels = 2
    data = ioData!.pointee.mBuffers.mData!.assumingMemoryBound(to: Float32.self)
    data[frame.toInt] = Float32( sin( 2 * .pi * (j / cycleLength) ) )
    
    j += 1.0
    if j > cycleLength {
      j -= cycleLength
    }
  }
  
  // 파형이 어디에 위치하는지 컨텍스트 개게로 추적할 필요가 있고,
  // 따라서 렌더링한 마지막 샘플이 파장의 중간 지점에 있다면
  // 다음 콜백에서 그 지점에서 다시 시작할 수 있다. (렌터 콜백 버퍼는 파장과 정렬되지 않음)
  playerPointer.pointee.startingFrameCount = j
  
  return noErr
}

// MARK: - Main

func AudioUnitSineWave_main() {
  var player = SineWavePlayer()
  
  // 유닛과 콜백을 설정
  createAndConnectOutput(&player)
  
  guard let outputAU = player.outputAU else {
    fatalError("ERROR: outputAU is nil")
  }
  
  // 재생 시작: 오디오 유닛을 직접 다루므로 그래프 대신 AUStart 사용
  checkError("Couldn't start output unit") {
    AudioOutputUnitStart(outputAU)
  }
  
  // 5초간 재생
  sleep(5)
  
  do {
    AudioOutputUnitStop(outputAU)
    AudioUnitUninitialize(outputAU)
    AudioComponentInstanceDispose(outputAU)
  }
}

/*
 ...
 [SineWaveProc] needs 512 frames at 762961517.909600
 [SineWaveProc] needs 512 frames at 762961517.921310
 [SineWaveProc] needs 512 frames at 762961517.932934
 ...
 
 타임스탬프간 간격은 약 0.0116초로 일정, 이는 11.6밀리초마다 콜백 함수가 호출됨을 의미
 */
