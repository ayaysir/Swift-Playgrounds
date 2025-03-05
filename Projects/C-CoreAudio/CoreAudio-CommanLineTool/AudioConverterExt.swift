//
//  AudioConverterExt.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/5/25.
//

import Foundation
import AudioToolbox

// MARK: - User Data Struct

fileprivate struct AudioConverterSettings {
  var outputFormat = AudioStreamBasicDescription()
  var inputFileRef: ExtAudioFileRef?
  var outputFileID: AudioFileID?
}

// MARK: - Utility Functions

fileprivate func convert(settings: inout AudioConverterSettings) {
  // 패킷 버퍼 배열 크기와 가변 비트율 데이터의 버퍼당 패킷 수 결정
  
  let outputBufferSize: UInt32 = 32 * 1024 // 기본 버퍼 크기: 32KB
  let sizePerPacket: UInt32 = settings.outputFormat.mBytesPerPacket
  let packetsPerBuffer: UInt32 = outputBufferSize / sizePerPacket
  
  // ✅
  let bytesPerFrame: UInt32 = settings.outputFormat.mBytesPerFrame
  
  // 이부분은 4배속 문제와 관련없음
  let outputBuffeMemSize = MemoryLayout<UInt8>.size * outputBufferSize.toInt
  let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBuffeMemSize)
  
  var outputFilePacketPosition: UInt32 = 0 // 바이트
  
  while true {
    var convertedData = AudioBufferList(
      mNumberBuffers: 1,
      mBuffers: AudioBuffer(
        mNumberChannels: settings.outputFormat.mChannelsPerFrame,
        mDataByteSize: outputBufferSize,
        mData: outputBuffer
      )
    )
    
    var frameCount: UInt32 = packetsPerBuffer
    checkError("Couldn't read from input file") {
      ExtAudioFileRead(
        settings.inputFileRef!,
        &frameCount,
        &convertedData
      )
    }
    
    // 프레임을 읽지 않은 경우 종료
    if frameCount == 0 {
      print("Done reading from file.")
      return
    }
    
    // ✅ 올바른 패킷 위치 계산
    let inStartingPacket = Int64(outputFilePacketPosition / bytesPerFrame)
    
    checkError("Couldn't write packets to file") {
      AudioFileWritePackets(
        settings.outputFileID!,
        false,
        frameCount * bytesPerFrame, // ✅
        nil, // PCM 출력 파일은 고정 비트율이므로 패킷 정보 사용 안함
        inStartingPacket, // inStartingPacket: Int64,
        &frameCount,
        convertedData.mBuffers.mData!
      )
    }
    
    // 출력 파일 쓰기 위치 이동
    outputFilePacketPosition += frameCount * settings.outputFormat.mBytesPerPacket
  }
}

fileprivate func convertWithLogs(settings: inout AudioConverterSettings) {
  // 패킷 버퍼 배열 크기와 가변 비트율 데이터의 버퍼당 패킷 수 결정
  
  let outputBufferSize: UInt32 = 32 * 1024 // 기본 버퍼 크기: 32KB
  print("outputBufferSize: \(outputBufferSize)")
  
  let sizePerPacket: UInt32 = settings.outputFormat.mBytesPerPacket
  print("sizePerPacket: \(sizePerPacket)")
  
  let packetsPerBuffer: UInt32 = outputBufferSize / sizePerPacket
  // let packetsPerBuffer: UInt32 = outputBufferSize / settings.outputFormat.mBytesPerFrame
  print("packetsPerBuffer: \(packetsPerBuffer)")
  
  // ✅
  let bytesPerFrame: UInt32 = settings.outputFormat.mBytesPerFrame
  
  let outputBuffeMemSize = MemoryLayout<UInt8>.size * outputBufferSize.toInt
  print("outputBuffeMemSize: \(outputBuffeMemSize)")
  
  let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: outputBuffeMemSize)
  print("outputBuffer allocated with capacity: \(outputBuffeMemSize)")
  
  var outputFilePacketPosition: UInt32 = 0 // 바이트
  print("outputFilePacketPosition initialized: \(outputFilePacketPosition)")
  
  while true {
    var convertedData = AudioBufferList(
      mNumberBuffers: 1,
      mBuffers: AudioBuffer(
        mNumberChannels: settings.outputFormat.mChannelsPerFrame,
        mDataByteSize: outputBufferSize,
        mData: outputBuffer
      )
    )
    print("convertedData initialized with mNumberBuffers: \(convertedData.mNumberBuffers), mDataByteSize: \(convertedData.mBuffers.mDataByteSize)")
    
    var frameCount: UInt32 = packetsPerBuffer
    print("frameCount before read: \(frameCount)")
    
    checkError("Couldn't read from input file") {
      ExtAudioFileRead(
        settings.inputFileRef!,
        &frameCount,
        &convertedData
      )
    }
    
    print("frameCount after read: \(frameCount)")
    
    // 프레임을 읽지 않은 경우 종료
    if frameCount == 0 {
      print("Done reading from file.")
      return
    }
    
    // ✅ 올바른 패킷 위치 계산
    let inStartingPacket = Int64(outputFilePacketPosition / bytesPerFrame)
    print("Writing packets at position: \(inStartingPacket), frameCount: \(frameCount)")
    
    checkError("Couldn't write packets to file") {
      AudioFileWritePackets(
        settings.outputFileID!,
        false,
        frameCount * bytesPerFrame, // ✅
        nil, // PCM 출력 파일은 고정 비트율이므로 패킷 정보 사용 안함
        // Int64(outputFilePacketPosition / settings.outputFormat.mBytesPerPacket), // inStartingPacket: Int64,
        inStartingPacket, // ✅
        &frameCount,
        convertedData.mBuffers.mData!
      )
    }
    
    // 출력 파일 쓰기 위치 이동
    // outputFilePacketPosition += frameCount * settings.outputFormat.mBytesPerPacket
    outputFilePacketPosition += frameCount * bytesPerFrame // ✅
    print("outputFilePacketPosition updated: \(outputFilePacketPosition)")
  }
}



// MARK: - Main

func AudioConverterExt_main() {
  var settings = AudioConverterSettings()
  print("[AudioConverterExt] 변환할 오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 변환을 위한 오디오 파일 열기
  let inputFileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(inputFileURL.absoluteString)
  
  checkError("ExtAudioFileOpenURL failed") {
    ExtAudioFileOpenURL(
      inputFileURL as CFURL,
      &settings.inputFileRef
    )
  }
  
  settings.outputFormat.mSampleRate = 44100.0
  settings.outputFormat.mFormatID = kAudioFormatLinearPCM
  settings.outputFormat.mFormatFlags = kAudioFormatFlagIsBigEndian |
                                                  kAudioFormatFlagIsSignedInteger |
                                                  kAudioFormatFlagIsPacked
  
  settings.outputFormat.mBitsPerChannel = 16
  settings.outputFormat.mChannelsPerFrame = 2
  settings.outputFormat.mBytesPerPacket = 4
  settings.outputFormat.mBytesPerFrame = 4
  settings.outputFormat.mFramesPerPacket = 1
  
  let inputFileName = inputFileURL.deletingPathExtension().lastPathComponent
  let outputFileURL = URL(fileURLWithPath: "Converted_ext_\(inputFileName).aif")
  
  checkError("AudioFileCreateWithURL failed") {
    AudioFileCreateWithURL(
      outputFileURL as CFURL,
      kAudioFileAIFFType,
      &settings.outputFormat,
      .eraseFile,
      &settings.outputFileID
    )
  }
  
  // 확장된 오디오 파일에 클라이언트 데이터 형식 속성 설정
  checkError("Couldn't set client data format on input ext file") {
    ExtAudioFileSetProperty(
      settings.inputFileRef!,
      kExtAudioFileProperty_ClientDataFormat,
      MemoryLayout<AudioStreamBasicDescription>.size.toUInt32,
      &settings.outputFormat
    )
  }
  
  print("Converting...")
  convert(settings: &settings)
  
  do {
    AudioFileClose(settings.inputFileRef!)
    AudioFileClose(settings.outputFileID!)
    print("Finished: \(outputFileURL.absoluteString)")
  }
}
