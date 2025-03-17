//
//  AudioMananger.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/16/25.
//

import Foundation
import AudioToolbox
import AVFoundation

let FOREGROUND_FREQ = 880.0
let BACKGROUND_FREQ = 523.25
let BUFFER_COUNT = 3
let BUFFER_DURATION = 0.5

final class AudioManager: ObservableObject {
  var player = AudioPlayer()
  
  var publisher = NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
  
  private let CustomAQOutputCallback: AudioQueueOutputCallback = {
    inUserData,
    inAQ,
    inBuffer in
    guard let inUserData else {
      print("User data is nil")
      return
    }
    
    let playerPtr = inUserData.assumingMemoryBound(to: AudioPlayer.self)
    
    let fillBufferResult = AudioManager.fillBuffer(inBuffer, player: &playerPtr.pointee)
    guard check(fillBufferResult) else {
      print("ERROR: fillBuffer is failed.")
      return
    }
    
    AudioQueueEnqueueBuffer(
      inAQ,
      inBuffer,
      0,
      nil
    )
  }
  
  static func fillBuffer(_ buffer: AudioQueueBufferRef, player: inout AudioPlayer) -> OSStatus {
    /// 프레임 수로 측정되는 파형의 오프셋 (또는 위상)을 나타내는 지역 변수
    var j: Double = player.startingFrameCount
    /// 사이클 길이(또는 파장) 설정
    let cycleLength: Double = 44100.0 / player.currentFrequency
    let frameCount: Int = .init(player.bufferSize / player.streamFormat.mBytesPerFrame)
    
    for frame in 0..<frameCount {
      let data = buffer.pointee.mAudioData.assumingMemoryBound(to: Float32.self)
      
      // (data) [frame] = (Float32) sin( 2* M_PI * (j / cycleLength);
      // 0.1 => 음량
      data[frame] = Float32( sin( 2 * .pi * (j / cycleLength) ) ) * 0.5
      
      j += 1.0
      if j > cycleLength {
        j -= cycleLength
      }
    }
    
    player.startingFrameCount = 1
    buffer.pointee.mAudioDataByteSize = player.bufferSize
    
    return noErr
  }
  
  static func audioSessionInitialize(category: AVAudioSession.Category) {
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
      try audioSession.setCategory(category)
      try audioSession.setActive(true)
      print("\(#function) is activated: \(category.rawValue)")
    } catch {
      print("ERROR: \(#function) is failed.")
    }
  }
  
  func audioQueueInitialize() {
    player.currentFrequency = FOREGROUND_FREQ
    
    // 오디오 큐 생성
    var streamFormat = player.streamFormat
    var audioQueue = player.audioQueue
    
    let result = AudioQueueNewOutput(
      &streamFormat,
      CustomAQOutputCallback,
      &player,
      nil,
      CFRunLoopMode.commonModes.rawValue,
      0,
      &audioQueue
    )
    
    player.streamFormat = streamFormat
    player.audioQueue = audioQueue
    
    guard check(result) else {
      print("Error: AudioQueueNewOutput failed.")
      return
    }
    
    guard let audioQueue = player.audioQueue else {
      print("ERROR: audioQueue is nil")
      return
    }
    
    let buffers: UnsafeMutablePointer<AudioQueueBufferRef?> = .allocate(capacity: BUFFER_COUNT)
    player.bufferSize = UInt32(BUFFER_DURATION * player.streamFormat.mSampleRate) * UInt32(player.streamFormat.mBytesPerFrame)
    print("BufferSize is \(player.bufferSize)")
    
    for i in 0..<BUFFER_COUNT {
      guard check(AudioQueueAllocateBuffer(
        audioQueue,
        player.bufferSize,
        &buffers[i]
      )) else {
        print("AudioQueueAllocateBuffer \(i) failed.")
        return
      }
      
      let fillBufferResult = Self.fillBuffer(buffers[i]!, player: &player)
      guard check(fillBufferResult) else {
        print("fillBufferResult \(i) failed.")
        return
      }
      
      guard check(AudioQueueEnqueueBuffer(
        audioQueue,
        buffers[i]!,
        0,
        nil
      )) else {
        print("AudioQueueEnqueueBuffer \(i) failed.")
        return
      }
    }
  }
  
  func startAudioQueue() {
    audioQueueInitialize()
    
    guard let audioQueue = player.audioQueue else {
      print("ERROR at \(#line): audioQueue is nil.")
      return
    }
    
    guard check(AudioQueueStart(
      audioQueue,
      nil
    )) else {
      print("AudioQueueStart failed.")
      return
    }
  }
  
  func stopAudioQueue() {
    guard let audioQueue = player.audioQueue else {
      print("ERROR at \(#line): audioQueue is nil.")
      return
    }
    
    guard check(AudioQueueStop(
      audioQueue,
      true
    )) else {
      print("AudioQueueStop failed.")
      return
    }
  }
  
  func chnageFrequency(to freq: Double) {
    player.currentFrequency = freq
  }
  
  func handleInterruption(notification: Notification) {
    guard let userInfo = notification.userInfo,
          let typeKeyRaw = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
          let typeKey = AVAudioSession.InterruptionType(rawValue: typeKeyRaw) else {
      print("typeKey is nil.")
      return
    }
   
    switch typeKey {
    case .began:
      stopAudioQueue()
    case .ended:
      startAudioQueue()
    @unknown default:
      break
    }
  }
}
