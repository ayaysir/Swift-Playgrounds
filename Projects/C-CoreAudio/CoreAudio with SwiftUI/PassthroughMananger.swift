//
//  PassthroughMananger.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/17/25.
//

import Foundation
import AVFoundation
import AudioToolbox

typealias AudioSampleType = Int16

@Observable
final class PassthroughManager {
  var effectState = EffectState()

  /// 오디오 입력 가능한지 여부 조사
  func checkAudioInputAvailable() async -> Bool {
    await withCheckedContinuation { continuation in
      AVAudioApplication.requestRecordPermission { granted in
        if granted {
          let inputAvailable = AVAudioSession.sharedInstance().isInputAvailable
          print("Audio input available: \(inputAvailable)")
          continuation.resume(returning: inputAvailable)
        } else {
          print("Microphone access denied")
          continuation.resume(returning: false)
        }
      }
    }
  }

  /// iOS 장치에서 하드웨어 샘플율 얻기
  func getHardwareSampleRate() -> Double {
    AVAudioSession.sharedInstance().sampleRate
  }

  func setupRemoteIOUnit() {
    var result = noErr
    print("sampleRate: \(getHardwareSampleRate())")
    // try? AVAudioSession.sharedInstance().setPreferredSampleRate(44100)
    
    // 1. IO 유닛 얻기
    // 유닛 설명
    var audioCompDesc = AudioComponentDescription(
      componentType: kAudioUnitType_Output,
      componentSubType: kAudioUnitSubType_RemoteIO,
      componentManufacturer: kAudioUnitManufacturer_Apple,
      componentFlags: 0,
      componentFlagsMask: 0
    )

    guard let rioComponent = AudioComponentFindNext(nil, &audioCompDesc) else {
      fatalError("ERROR: RemoteIO component not found.")
    }

    result = AudioComponentInstanceNew(rioComponent, &effectState.remoteIOUnit)
    guard check(result) else {
      fatalError("Error: AudioComponentInstanceNew failed.")
    }

    // 2: IO 유닛 활성화
    var oneFlag: UInt32 = 1
    let bus0: AudioUnitElement = 0
    let bus1: AudioUnitElement = 1

    guard let remoteIOUnit = effectState.remoteIOUnit else {
      fatalError("remoteIOUnit is nil.")
    }

    // 재생을 위해 유닛 설정
    result = AudioUnitSetProperty(
      remoteIOUnit,
      kAudioOutputUnitProperty_EnableIO,
      kAudioUnitScope_Output,
      bus0,
      &oneFlag,
      UInt32(MemoryLayout.size(ofValue: oneFlag))
    )
    guard check(result) else {
      fatalError("Couldn't enable output on remoteIOUnit")
    }
    
    // RemoteIO 입력을 활성화
    result = AudioUnitSetProperty(
      remoteIOUnit,
      kAudioOutputUnitProperty_EnableIO,
      kAudioUnitScope_Input,
      bus1,
      &oneFlag,
      UInt32(MemoryLayout.size(ofValue: oneFlag))
    )

    // 3. ASBD 설정
    var asbd = AudioStreamBasicDescription(
      mSampleRate: getHardwareSampleRate(),
      mFormatID: kAudioFormatLinearPCM,
      mFormatFlags: kAudioFormatFlagIsFloat,
      mBytesPerPacket: 4,
      mFramesPerPacket: 1,
      mBytesPerFrame: 4,
      mChannelsPerFrame: 1,
      mBitsPerChannel: 32,
      mReserved: 0
    )

    // RIO의 입력 스코프에서 출력(버스0)의 형식을 설정
    result = AudioUnitSetProperty(
      remoteIOUnit,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Input,
      bus0,
      &asbd,
      UInt32(MemoryLayout.size(ofValue: asbd))
    )
    guard check(result) else {
      fatalError("Couldn't set the ASBD for RemoteIO on input scope(bus0).")
    }

    // RIO의 출력 스코프에서 마이크 입력(버스1)을 위한 ASBD 설정
    result = AudioUnitSetProperty(
      remoteIOUnit,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Output,
      bus1,
      &asbd,
      UInt32(MemoryLayout.size(ofValue: asbd))
    )
    guard check(result) else {
      fatalError("Couldn't set the ASBD for RemoteIO on output scope(bus1).")
    }

    // Render Callback 설정
    effectState.asbd = asbd
    effectState.sineFrequency = 30
    effectState.sinePhase = 0

    var callbackStruct = AURenderCallbackStruct()
    callbackStruct.inputProc = Self.InputModulatingRenderCallback
    withUnsafeMutablePointer(to: &effectState) { pointer in
      callbackStruct.inputProcRefCon = UnsafeMutableRawPointer(pointer)
    }

    result = AudioUnitSetProperty(
      remoteIOUnit,
      kAudioUnitProperty_SetRenderCallback,
      kAudioUnitScope_Global,
      bus0,
      &callbackStruct,
      UInt32(MemoryLayout.size(ofValue: callbackStruct))
    )
    guard check(result) else {
      fatalError("Couldn't set RemoteIO's render callback on bus0.")
    }

    // 4. 유닛 시작
    result = AudioUnitInitialize(remoteIOUnit)
    guard check(result) else {
      fatalError("Couldn't initialize remoteIOUnit.")
    }

    result = AudioOutputUnitStart(remoteIOUnit)
    guard check(result) else {
      fatalError("Couldn't start remoteIOUnit.")
    }

    print("RemoteIO started!")
  }

  static let InputModulatingRenderCallback: AURenderCallback = {
    inRefCon,
    ioActionFlags,
    inTimeStamp,
    inBusNumber,
    inNumberFrames,
    ioData in
    
    let statePtr = inRefCon.assumingMemoryBound(to: EffectState.self)
    
    guard let remoteIOUnit = statePtr.pointee.remoteIOUnit else {
      fatalError("ERROR: remoteIOUnit is nil.")
    }
    
    guard let ioData else {
      fatalError("ERROR: ioData is nil.")
    }

    // 단순 샘플 복사
    var bus1: UInt32 = 1
    var result = AudioUnitRender(
      remoteIOUnit,
      ioActionFlags,
      inTimeStamp,
      bus1,
      inNumberFrames,
      ioData
    )
    guard check(result) else {
      fatalError("ERROR: AudioUnitRender failed.")
    }
    
    // 샘플 버퍼에 링 모듈레이션(Ring Modulation) 효과 실행
    var sample: AudioSampleType = 0
    var bytesPerChannel: UInt32 = statePtr.pointee.asbd.mBytesPerFrame / statePtr.pointee.asbd.mChannelsPerFrame
    
    for bufCount in 0..<UInt32(ioData.pointee.mNumberBuffers) {
      var buf: AudioBuffer = ioData.pointee.mBuffers
      buf.mNumberChannels = UInt32(BUFFER_COUNT)
      var currentFrame = 0
      
      while currentFrame < Int(inNumberFrames) {
        // 샘플의 모든 채널의 버퍼로 복사
        for currentChannel in 0..<Int(buf.mNumberChannels) {
          /*
           memcpy(
            &sample,
            buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame) + (currentChannel * bytesPerChannel),
            sizeof(AudioSampleType)
           );
           */
          let sourcePtr = buf.mData!.advanced(by: (currentFrame * Int(statePtr.pointee.asbd.mBytesPerFrame)) + (currentChannel * Int(bytesPerChannel)))
          
          memcpy(&sample, sourcePtr, MemoryLayout<AudioSampleType>.size)
          // samplePtr.baseAddress!.pointee = sourcePtr.load(as: AudioSampleType.self)
          
          var theta: Float = statePtr.pointee.sinePhase * .pi * 2
          sample = AudioSampleType(sin(theta)) * sample
          
          /*
           memcpy(
            buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame) + (currentChannel * bytesPerChannel),
            &sample,
            sizeof(AudioSampleType)
           );
           */
          memcpy(sourcePtr, &sample, MemoryLayout<AudioSampleType>.size)
          // sourcePtr.storeBytes(of: samplePtr.baseAddress!.pointee, as: AudioSampleType.self)
          
          statePtr.pointee.sinePhase += 1.0 / (Float(statePtr.pointee.asbd.mSampleRate) / statePtr.pointee.sineFrequency)
          if statePtr.pointee.sinePhase > 1.0 {
            statePtr.pointee.sinePhase -= 1.0
          }
        }
        
        currentFrame += 1
      }
    }

    return noErr
  }
}
