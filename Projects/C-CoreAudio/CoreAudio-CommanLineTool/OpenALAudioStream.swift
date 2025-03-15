//
//  OpenALAudioStream.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/16/25.
//

import Foundation
import AudioToolbox
import OpenAL

// fileprivate let BUFFER_COUNT: Int32 = 30
fileprivate let BUFFER_DURATION: UInt32 = 5
fileprivate let ORBIT_SPEED = 1

// MARK: - User Data Struct

fileprivate struct StreamPlayer {
  var dataFormat = AudioStreamBasicDescription()
  var bufferSizeBytes: UInt32 = 0
  var fileLengthFrames: Int64 = 0
  var totalFramesRead: Int64 = 0
  var sources = UnsafeMutablePointer<ALuint>.allocate(capacity: 1)
  var extAudioFileRef: ExtAudioFileRef?
  
  init() {
    sources.initialize(repeating: 0, count: 1)
    
    dataFormat.mFormatID = kAudioFormatLinearPCM
    dataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
    dataFormat.mSampleRate = 44100.0
    dataFormat.mChannelsPerFrame = 1
    dataFormat.mFramesPerPacket = 1
    dataFormat.mBitsPerChannel = 16
    dataFormat.mBytesPerFrame = 2
    dataFormat.mBytesPerPacket = 2
  }
  
  var duration: Double {
    Double(fileLengthFrames) / dataFormat.mSampleRate
  }
  
  var bufferCount: Int32 {
    Int32(duration / Double(BUFFER_DURATION))
  }
}

// MARK: - Utility Functions

// CheckError(): 분리

/// (0, 0, 0)을 중심으로 3차원의 타원 궤도를 만든다
/// - 넓은 왼쪽에서 오른쪽으로 지나가는 소리를 기대한다
fileprivate func updateSourceLocation(_ player: inout StreamPlayer) {
  /*
   x = 3cos(theta)
   y = 1/2sin(theta)
   z = sin(theta)
   */
  
  let theta: Double = fmod(CFAbsoluteTimeGetCurrent() * Double(ORBIT_SPEED), .pi * 2)
  let x: ALfloat = .init(3 * cos(theta))
  let y: ALfloat = .init(0.5 * sin(theta))
  let z: ALfloat = .init(1.0 * sin(theta))
  
  alSource3f(player.sources[0], AL_POSITION, x, y, z)
}

fileprivate func setupExtAudioFile(_ player: inout StreamPlayer, fileURL: URL) -> OSStatus {
  // Set player.dataFormat
  
  checkError("Couldn't open ExtAudioFile for reading") {
    ExtAudioFileOpenURL(fileURL as CFURL, &player.extAudioFileRef)
  }
  
  guard let extAudioFileRef = player.extAudioFileRef else {
    fatalError("ERROR: extAudioFileRef is nil")
  }
  
  // 형식에 대해 extAudioFileRef에 알려줌
  checkError("Couldn't set client format on ExtAudioFile") {
    ExtAudioFileSetProperty(
      extAudioFileRef,
      kExtAudioFileProperty_ClientDataFormat,
      MemoryLayout<AudioStreamBasicDescription>.size.toUInt32,
      &player.dataFormat
    )
  }
  
  // 파일의 크기 계산
  var propSize = MemoryLayout.size(ofValue: player.fileLengthFrames).toUInt32
  ExtAudioFileGetProperty(
    extAudioFileRef,
    kExtAudioFileProperty_FileLengthFrames,
    &propSize,
    &player.fileLengthFrames
  )
  print(String(format: "fileLengthFrames = %lld frames", player.fileLengthFrames))
  
  // 음원의 길이를 초 단위로 계산
  let fileDurationInSeconds = Double(player.fileLengthFrames) / player.dataFormat.mSampleRate
  print(String(format: "File duration = %.2f seconds", fileDurationInSeconds))
  
  player.bufferSizeBytes = BUFFER_DURATION * UInt32(player.dataFormat.mSampleRate) * player.dataFormat.mBytesPerFrame
  print("bufferSizeBytes = \(player.bufferSizeBytes)")
  
  print("Bottom of \(#function)")
  return noErr
}

fileprivate func fillALBuffer(_ player: inout StreamPlayer, alBuffer: ALuint) {
  // ExtAudioFile에서 읽기 위해서 AudioBufferList와 하나의 AudioBuffer 설정
  // 샘플 버퍼 할당
  
  var bufferList = AudioBufferList()
  let sampleBuffer = UnsafeMutablePointer<UInt16>.allocate(capacity: player.bufferSizeBytes.toInt)
  
  bufferList.mNumberBuffers = 1
  bufferList.mBuffers.mNumberChannels = 1
  bufferList.mBuffers.mDataByteSize = player.bufferSizeBytes
  bufferList.mBuffers.mData = UnsafeMutableRawPointer(sampleBuffer)
  
  print("allocated \(player.bufferSizeBytes) byte buffer for ABL")
  
  // ExtAudioFile에서 읽기
  var framesReadIntoBuffer: UInt32 = 0
  repeat {
    var framesRead = UInt32(player.fileLengthFrames) - framesReadIntoBuffer
    
    bufferList.mBuffers.mData = UnsafeMutableRawPointer(sampleBuffer + (framesReadIntoBuffer.toInt * MemoryLayout<UInt16>.size))
    
    checkError("ExtAudioFileRead failed") {
      ExtAudioFileRead(
        player.extAudioFileRef!,
        &framesRead,
        &bufferList
      )
    }
    
    // **읽은 프레임이 0이면 파일 끝에 도달했음을 의미**
    if framesRead == 0 {
      print("No frames to read.")
      break
    }
    
    framesReadIntoBuffer += framesRead
    player.totalFramesRead += Int64(framesRead) // ??
    
    print("read \(framesRead) frames")
  } while framesReadIntoBuffer < (player.bufferSizeBytes / MemoryLayout<UInt16>.size.toUInt32)
  
  // sampleBuffer에서 AL 버퍼로 복사
  alBufferData(
    alBuffer,
    AL_FORMAT_MONO16,
    sampleBuffer,
    ALsizei(player.bufferSizeBytes),
    ALsizei(player.dataFormat.mSampleRate)
  )
  
  sampleBuffer.deallocate()
}

fileprivate func refillALBuffers(_ player: inout StreamPlayer) {
  // 빈 스트리밍 버퍼를 위해 OpenAL 소스를 검사
  var processed: ALint = 0
  alGetSourcei(
    player.sources[0],
    AL_BUFFERS_PROCESSED,
    &processed
  )
  checkAL("Couldn't get al_buffers_processed")
  
  // OpenAL을 큐에서 꺼내고 다시 채움
  while processed > 0 {
    var freeBuffer: ALuint = 0
    
    alSourceUnqueueBuffers(
      player.sources[0],
      1,
      &freeBuffer
    )
    checkAL("Couldn't unqueue buffer")
    
    print("Refilling buffer \(freeBuffer)")
    
    alSourceQueueBuffers(
      player.sources[0],
      1,
      &freeBuffer
    )
    checkAL("Couldn't queue refilled buffer")
    
    print("Re-queued buffer \(freeBuffer)")
    processed -= 1
  }
}

// MARK: - Main

func OpenALAudioStream_main() {
  var player = StreamPlayer()
  
  print("[\(#function)] 재생할 오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 입력을 위한 오디오 파일 열기
  let fileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(fileURL.absoluteString)
  
  checkError("Couldn't open ExtAudioFile") {
    setupExtAudioFile(&player, fileURL: fileURL)
  }
  
  // 기본 OpenAL 장치를 열고 컨텍스트 만들기
  var alDevice: OpaquePointer = alcOpenDevice(nil)
  checkAL("Couldn't open AL device")
  var alContext = alcCreateContext(alDevice, nil)
  checkAL("Couldn't open AL context")
  alcMakeContextCurrent(alContext)
  checkAL("Couldn't make AL context current")
  
  // 스트리밍을 위해 OpenAL을 생성하고 채움
  let buffers = UnsafeMutablePointer<ALuint>.allocate(capacity: Int(player.bufferCount))
  buffers.initialize(repeating: 0, count: Int(player.bufferCount))
  alGenBuffers(player.bufferCount, buffers)
  checkAL("Couldn't generate buffers")
  
  for i in 0..<player.bufferCount {
    fillALBuffer(&player, alBuffer: buffers[Int(i)])
  }
  
  // 스트리밍을 위해 OpenAL 소스 생성
  alGenSources(1, player.sources)
  checkAL("Couldn't generate sources")
  
  // 소스에 AL_GAIN 속성 설정
  alSourcef(player.sources[0], AL_GAIN, ALfloat(AL_MAX_GAIN))
  checkAL("Couldn't set source gain")
  
  // 최초 소스 위치 설정
  updateSourceLocation(&player)
  checkAL("Couldn't set initial source position")
  
  // 스트리밍을 위한 OpenAL 소스의 버퍼를 큐에 넣음
  alSourceQueueBuffers(
    player.sources[0],
    player.bufferCount,
    buffers
  )
  checkAL("Couldn't queue buffers on source")
  
  // 리스너를 만들고 스트림 궤도를 돌기 소스를 시자
  // 리스너의 최초 위치 설정
  alListener3f(AL_POSITION, 0, 0, 0)
  checkAL("Couldn't set listener position")
  
  // 재생
  alSourcePlayv(1, player.sources)
  checkAL("Couldn't start playback")
  
  print("Playing...")
  let startTime = time(nil)
  
  repeat {
    // 다음 세타를 얻음
    updateSourceLocation(&player)
    checkAL("Couldn't set looping source position")
    
    // 필요한 경우 버퍼를 다시 채움
    refillALBuffers(&player)
    
    CFRunLoopRunInMode(
      .defaultMode,
      0.1,
      false
    )
  } while difftime(time(nil), startTime) < player.duration
  
  do {
    alSourceStop(player.sources[0])
    alDeleteSources(1, player.sources)
    alDeleteBuffers(player.bufferCount, buffers)
    alcDestroyContext(alContext)
    alcCloseDevice(alDevice)
    print("Bottom of \(#function)")
  }
}
