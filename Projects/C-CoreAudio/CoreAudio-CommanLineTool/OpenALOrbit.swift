//
//  OpenALOrbit.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/15/25.
//

import Foundation
import AudioToolbox
import OpenAL

fileprivate let RUN_TIME = 20.0
fileprivate let ORBIT_SPEED = 1

// MARK: - User Data Struct
fileprivate struct LoopPlayer {
  var dataFormat = AudioStreamBasicDescription()
  var sampleBuffer: UnsafeMutablePointer<UInt16>?
  var bufferSizeBytes: UInt32 = 0
  var sources = UnsafeMutablePointer<ALuint>.allocate(capacity: 1)
  
  init() {
    sources.initialize(repeating: 0, count: 1)
  }
}

// MARK: - Utility Functions

// CheckError(): 분리

/// (0, 0, 0)을 중심으로 3차원의 타원 궤도를 만든다
/// - 넓은 왼쪽에서 오른쪽으로 지나가는 소리를 기대한다
fileprivate func updateSourceLocation(_ player: inout LoopPlayer) {
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

fileprivate func loadLoopIntoBuffer(_ player: inout LoopPlayer, fileURL: URL) -> OSStatus {
  var extAudioFileRef: ExtAudioFileRef?
  checkError("Couldn't open ExtAudioFile for reading") {
    ExtAudioFileOpenURL(fileURL as CFURL, &extAudioFileRef)
  }
  
  // ASBD로써 AL_FORMAT_MONO16 형식을 설명하고 ExtAudioFile로 사용하기
  // memset(&player->dataFormat, 0, sizeof(player->dataFormat));
  player.dataFormat.mFormatID = kAudioFormatLinearPCM
  player.dataFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked
  player.dataFormat.mSampleRate = 44100.0
  player.dataFormat.mChannelsPerFrame = 1
  player.dataFormat.mFramesPerPacket = 1
  player.dataFormat.mBitsPerChannel = 16
  player.dataFormat.mBytesPerFrame = 2
  player.dataFormat.mBytesPerPacket = 2
  
  // 형식에 대해 extAudioFileRef에 알려줌
  checkError("Couldn't set client format on ExtAudioFile") {
    ExtAudioFileSetProperty(
      extAudioFileRef!,
      kExtAudioFileProperty_ClientDataFormat,
      MemoryLayout<AudioStreamBasicDescription>.size.toUInt32,
      &player.dataFormat
    )
  }
  
  // ExtAudioFile에서 OpenAL로 전환하기 위해 읽기 버퍼를 할당
  var fileLengthFrames: Int64 = 0
  var propSize: UInt32 = MemoryLayout.size(ofValue: fileLengthFrames).toUInt32
  checkError("Couldn't get file length") {
    ExtAudioFileGetProperty(
      extAudioFileRef!,
      kExtAudioFileProperty_FileLengthFrames,
      &propSize,
      &fileLengthFrames
    )
  }
  
  player.bufferSizeBytes = UInt32(fileLengthFrames) * player.dataFormat.mBytesPerFrame
  
  // var buffers: UnsafeMutableRawPointer!
  // var ablSize = MemoryLayout<AudioBufferList>.offset(of: \.mBuffers)! + MemoryLayout<AudioBuffer>.size * 1
  // 
  // buffers = UnsafeMutableRawPointer.allocate(
  //   byteCount: ablSize,
  //   alignment: MemoryLayout<AudioBufferList>.alignment
  // )
  // memset(buffers, 0, ablSize)
  var buffers = AudioBufferList()
  
  player.sampleBuffer = UnsafeMutablePointer<UInt16>.allocate(capacity: player.bufferSizeBytes.toInt)
  buffers.mNumberBuffers = 1
  buffers.mBuffers.mNumberChannels = 1
  buffers.mBuffers.mDataByteSize = player.bufferSizeBytes
  buffers.mBuffers.mData = UnsafeMutableRawPointer(player.sampleBuffer)
  
  // OpenAL 버퍼에 사용을 위해 ExtAudioFile로 데이터를 읽음
  // 버퍼가 찰 때까지 ABL에 계속 읽어들임
  var totalFramesRead: UInt32 = 0
  repeat {
    var framesRead = UInt32(fileLengthFrames) - totalFramesRead
    // 연속적인 읽기를 하는 동안
    buffers.mBuffers.mData = UnsafeMutableRawPointer(player.sampleBuffer! + (totalFramesRead.toInt * MemoryLayout<UInt16>.size))
    checkError("ExtAudioFileRead failed") {
      ExtAudioFileRead(
        extAudioFileRef!,
        &framesRead,
        &buffers
      )
    }
    totalFramesRead += framesRead
    print(String(format: "read %d frames", framesRead))
  } while totalFramesRead < fileLengthFrames
  
  return noErr
}


// MARK: - Main

func OpenALOrbit_main() {
  var player = LoopPlayer()
  
  print("재생할 오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 입력을 위한 오디오 파일 열기
  let fileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(fileURL.absoluteString)
  
  // OpenAL에 익숙한 형식으로 변환하고 메모리 로딩
  checkError("Couldn't load loop into buffer") {
    loadLoopIntoBuffer(&player, fileURL: fileURL)
  }
  
  // 기본 OpenAL 장치를 열고 컨텍스트 만들기
  var alDevice: OpaquePointer = alcOpenDevice(nil)
  checkAL("Couldn't open AL device")
  var alContext = alcCreateContext(alDevice, nil)
  checkAL("Couldn't open AL context")
  alcMakeContextCurrent(alContext)
  checkAL("Couldn't make AL context current")
  
  // OpenAL 버퍼 생성
  var buffers = UnsafeMutablePointer<ALuint>.allocate(capacity: 1)
  buffers.initialize(repeating: 0, count: 1)
  alGenBuffers(1, buffers)
  checkAL("Couldn't generate buffers")
  
  // 오디오 샘플의 버퍼를 OpenAL 버퍼에 붙임
  alBufferData(
    buffers.pointee,
    AL_FORMAT_MONO16,
    player.sampleBuffer,
    Int32(player.bufferSizeBytes),
    Int32(player.dataFormat.mSampleRate)
  )
  
  // 샘플 버퍼의 내용이 복사된 이후 해제
  player.sampleBuffer?.deallocate()
  
  // OpenAL 소스 생성
  alGenSources(1, player.sources)
  checkAL("Couldn't generate sources")
  
  // 소스에 AL_LOOPING과 AL_GAIN 속성 설정
  alSourcei(player.sources[0], AL_LOOPING, AL_TRUE)
  checkAL("Couldn't set source looping property")
  
  alSourcef(player.sources[0], AL_GAIN, ALfloat(AL_MAX_GAIN))
  checkAL("Couldn't set source gain")
  
  // 최초 소스 위치 설정
  updateSourceLocation(&player)
  checkAL("Couldn't set initial source position")
  
  // 버퍼를 소스에 붙임
  alSourcei(player.sources[0], AL_BUFFER, ALint(buffers[0]))
  checkAL("Couldn't connect buffer to source")
  
  // 리스너의 최초 위치 설정
  alListener3f(AL_POSITION, 0, 0, 0)
  checkAL("Couldn't set listener position")
  
  // 소스 재생
  alSourcePlay(player.sources[0])
  checkAL("Couldn't play source")
  
  // 소스 위치 이동을 위한 반복문
  print("Playing...")
  var startTime = time(nil)
  repeat {
    // get next theta
    updateSourceLocation(&player)
    checkAL("Couldn't set looping source position")
    CFRunLoopRunInMode(
      .defaultMode,
      0.1,
      false
    )
  } while difftime(time(nil), startTime) < RUN_TIME
  
  do {
    alSourceStop(player.sources[0])
    alDeleteSources(1, player.sources)
    alDeleteBuffers(1, buffers)
    alcDestroyContext(alContext)
    alcCloseDevice(alDevice)
    print("Bottom of \(#function)")
  }
}
