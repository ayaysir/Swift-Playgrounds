//
//  AudioQueuePlayer.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/3/25.
//

import Foundation
import AudioToolbox

fileprivate let kNumberPlaybackBuffers = 3

// MARK: - User Data Struct

fileprivate struct Player {
  var playbackFile: AudioFileID?
  var packetPosition: Int64 = 0
  var numPacketsToRead: UInt32 = 0
  // var packetDescs: AudioStreamPacketDescription? 을 사용해서 포인터 변환하는 것보다
  // USMP<ASPD>?를 사용하여 직접 전달해야 동작함
  var packetDescs: UnsafeMutablePointer<AudioStreamPacketDescription>?
  var isDone = true
}

// MARK: - Utility Functions

// CheckError(): 분리

func copyEncoderCookieToQueue(
  fileID: AudioFileID,
  queue :AudioQueueRef
) {
  var propSize: UInt32 = 0
  let result = AudioFileGetPropertyInfo(
    fileID,
    kAudioFilePropertyMagicCookieData,
    &propSize,
    nil
  )
  
  if result == noErr && propSize > 0 {
    let magicCookie = UnsafeMutablePointer<UInt8>.allocate(capacity: propSize.toInt)
    
    checkError("Get cookie from file failed.") {
      AudioFileGetProperty(
        fileID,
        kAudioFilePropertyMagicCookieData,
        &propSize,
        magicCookie
      )
    }
    
    checkError("Set cookie on queue failed.") {
      AudioQueueSetProperty(
        queue,
        kAudioQueueProperty_MagicCookie,
        magicCookie,
        propSize
      )
    }
    
    magicCookie.deallocate()
  }
}

func calculateBytesForTime(
  inAudioFile: AudioFileID,
  inDesc: AudioStreamBasicDescription,
  inSeconds: Float64,
  outBufferSize: inout UInt32,
  outNumPackets: inout UInt32
) {
  // 최대 패킷 크기: kAudioFilePropertyPacketSizeUpperBound에서 획득
  var maxPacketSize: UInt32 = 0
  var propSize: UInt32 = MemoryLayout.size(ofValue: maxPacketSize).toUInt32
  
  checkError("Couldn't get file's max packet size") {
    AudioFileGetProperty(
      inAudioFile,
      kAudioFilePropertyPacketSizeUpperBound,
      &propSize,
      &maxPacketSize
    )
  }
  
  let maxBufferSize = 0x10000 // 65536 (64KB)
  let minBufferSize = 0x4000 // 16384 (16KB)
  
  if inDesc.mFramesPerPacket > 0 {
    // 하나의 패킷에 몇 개의 프레임이 있는 경우
    // 초 단위 기간 동안 몇 개의 패킷이 소요되는지
    let numPacketsForTime = inDesc.mSampleRate / Float64(inDesc.mFramesPerPacket) * inSeconds
    // 충분한 버퍼 크기를 갖기 위해 최대 패킷 크기를 곱함
    outBufferSize = UInt32(numPacketsForTime) * maxPacketSize
  } else {
    // mFramesPerPacket이 0이라면 maxBufferSize와 maxPacketSize보다 큰 값을 선택
    outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize.toUInt32 : maxPacketSize
  }
  
  // 경계 검사
  if outBufferSize > minBufferSize,
     outBufferSize > maxPacketSize {
    outBufferSize = UInt32(maxBufferSize)
  } else {
    if outBufferSize < minBufferSize {
      outBufferSize = UInt32(minBufferSize)
    }
  }
  
  // outBufferSize를 각 콜백에서 얼마만큼 파일에서 안전하게 읽을 수 있는지
  // 최대 패킷 사이즈(각 콜백에서 사용) 으로 나눔
  outNumPackets = outBufferSize / maxPacketSize
}

// MARK: - Playback Callback Function

fileprivate func CustomAQPOutputCallback(
  _ inUserData: UnsafeMutableRawPointer?,
  _ inAQ: AudioQueueRef,
  _ inCompleteAQBuffer: AudioQueueBufferRef
) -> Void {
  guard let inUserData else {
    print("\(#function) Error: inUserData is nil.")
    exit(1)
  }
  /*
   assumingMemoryBound(to:) 사용: UnsafeMutableRawPointer를 UnsafeMutablePointer<Player>로 변환하여 특정 타입(Player)의 메모리로 취급합니다.
   */
  let playerPointer = inUserData.assumingMemoryBound(to: Player.self)
  
  if playerPointer.pointee.isDone {
    return
  }
  
  var numBytes: UInt32 = 0
  var nPackets: UInt32 = playerPointer.pointee.numPacketsToRead
  
  guard let playbackFile = playerPointer.pointee.playbackFile else {
    return
  }
  
  checkError("AudioFileReadPackets failed.") {
    // 'AudioFileReadPackets' was deprecated in macOS 10.10: no longer supported
    AudioFileReadPackets(
      playbackFile, // 읽을 파일
      false, // 캐시 여부
      &numBytes, // 실제로 읽혀진 바이트의 수를 받을 포인터
      playerPointer.pointee.packetDescs, // 패킷 정보를 가지는 버퍼의 포인터
      playerPointer.pointee.packetPosition, // 읽으려는 첫 번째 패킷의 인덱스
      &nPackets, // 읽을 최대 패킷 수의 포인터 (함수 리턴시 도출됨)
      inCompleteAQBuffer.pointee.mAudioData // 오디오 데이터 수신 버퍼의 포인터
    )
  }
  
  // **AudioFileReadPacketData(...) : -50 에러 발생으로 동작하지 않음**
  // print("Passed:", #function, "AudioFileReadPackets")
  
  // 재생을 위해 패킷을 큐에 넣음
  if nPackets > 0 {
    inCompleteAQBuffer.pointee.mAudioDataByteSize = numBytes
    AudioQueueEnqueueBuffer(
      inAQ,
      inCompleteAQBuffer,
      playerPointer.pointee.packetDescs != nil ? nPackets : 0,
      playerPointer.pointee.packetDescs
    )
    
    playerPointer.pointee.packetPosition += Int64(nPackets)
  } else {
    // 파일의 끝(nPackets가 0)에 도달하자마자 오디오 큐를 중지
    checkError("AudioQueueStop failed.") {
      // inImmediate: false (즉시 종료하지 않음)
      AudioQueueStop(inAQ, false)
    }
    
    playerPointer.pointee.isDone = true
  }
}

// MARK: - Main

fileprivate let kNumberRecordBuffers = 3

func AudioQueuePlayer_main() {
  var player = Player()
  print("오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 입력을 위한 오디오 파일 열기
  let fileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(fileURL.absoluteString)
  
  checkError("AudioFileOpenURL failed.") {
    AudioFileOpenURL(
      fileURL as CFURL,
      .readPermission,
      0,
      &player.playbackFile
    )
  }
  
  // 오디오 파일에서 ASBD 획득
  var dataFormat = AudioStreamBasicDescription()
  var propSize: UInt32 = MemoryLayout.size(ofValue: dataFormat).toUInt32
  
  guard let playbackFile = player.playbackFile else {
    print(#function, "playbackFile is nil.")
    exit(1)
  }
  
  checkError("Couldn't get file's data format.") {
    AudioFileGetProperty(
      playbackFile,
      kAudioFilePropertyDataFormat,
      &propSize,
      &dataFormat
    )
  }
  
  // 출력을 위한 새로운 오디오 큐 생성
  var queue: AudioQueueRef?
  checkError("AudioQueueNewOutput failed.") {
    AudioQueueNewOutput(
      &dataFormat,
      CustomAQPOutputCallback,
      &player,
      nil,
      nil,
      0,
      &queue
    )
  }
  
  // 재생 버퍼 크기와 패킷의 수를 계산하기 위한 calculateBytesForTime 호출
  var bufferByteSize: UInt32 = 0
  calculateBytesForTime(
    inAudioFile: playbackFile,
    inDesc: dataFormat,
    inSeconds: 0.5, // 버퍼 크기(초)
    outBufferSize: &bufferByteSize,
    outNumPackets: &player.numPacketsToRead
  )
  
  // 패킷 정보 배열(packetDescs)에 메모리 할당
  let isFormatVBR = dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0
  if isFormatVBR {
    let capacity = player.numPacketsToRead.toInt * MemoryLayout<AudioStreamPacketDescription>.size
    player.packetDescs = UnsafeMutablePointer<AudioStreamPacketDescription>
      .allocate(capacity: capacity)
    
    print(
      "size:",
      capacity,
      player.numPacketsToRead.toInt,
      MemoryLayout<AudioStreamPacketDescription>.size
    )
  } else {
    player.packetDescs = nil
  }
  
  guard let queue else {
    print(#function, "Queue is nil.")
    exit(1)
  }
  
  // 매직 쿠키 처리: copyEncoderCookieToQueue(player.playbackFile, queue);
  copyEncoderCookieToQueue(
    fileID: playbackFile,
    queue: queue
  )
  
  // 재생 버퍼를 할당하고, 큐에 넣음
  var buffers: [AudioQueueBufferRef?] = .init(repeating: nil, count: kNumberRecordBuffers)
  player.isDone = false
  player.packetPosition = 0
  
  for i in 0..<kNumberRecordBuffers {
    checkError("AudioQueueAllocateBuffer failed.") {
      AudioQueueAllocateBuffer(
        queue,
        bufferByteSize,
        &buffers[i]
      )
    }
    
    // AQOutputCallback(&player, queue, buffers[i]);
    CustomAQPOutputCallback(
      &player,
      queue,
      buffers[i]!
    )
    
    if player.isDone {
      break
    }
  }
  
  // 재생 오디오 큐 시작
  checkError("AudioQueueStart failed.") {
    AudioQueueStart(queue, nil)
  }
  
  print("Playing...")
  
  repeat {
    CFRunLoopRunInMode(
      CFRunLoopMode.defaultMode,
      0.25,
      false
    )
  } while !player.isDone
  
  // 큐가 버퍼에 있는 오디오를 재생하도록 보장하는 지연
  CFRunLoopRunInMode(
    CFRunLoopMode.defaultMode,
    4, // 2 ~ 등의 적절한 값
    false
  )
  
  // 오디오 큐와 오디오 파일 해제
  player.isDone = true
  checkError("AudioQueueStop failed.") {
    AudioQueueStop(queue, true)
  }
  
  print("AudioQueueStop successed.")
  
  AudioQueueDispose(queue, true)
  AudioFileClose(player.playbackFile!)
}
