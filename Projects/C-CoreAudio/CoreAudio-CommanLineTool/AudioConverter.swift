//
//  AudioConverter.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/4/25.
//

import Foundation
import AudioToolbox

// MARK: - User Data Struct
fileprivate struct AudioConverterSettings {
  var inputFormat = AudioStreamBasicDescription()
  var outputFormat = AudioStreamBasicDescription()
  
  var inputFileID: AudioFileID?
  var outputFileID: AudioFileID?
  
  var inputFilePacketIndex: UInt64 = 0
  var inputFilePacketCount: UInt64 = 0
  var inputFilePacketMaxSize: UInt32 = 0
  var inputFilePacketDescs: UnsafeMutablePointer<AudioStreamPacketDescription>?
  
  // void* sourceBuffer;
  var sourceBuffer: UnsafeMutableRawPointer?
}

// MARK: - Utility Functions

// CheckError(): 분리

func printAudioDescription(_ format: AudioStreamBasicDescription, label: String) {
    print("\n=== \(label) ===")
    print("Sample Rate: \(format.mSampleRate)")
    print("Channels: \(format.mChannelsPerFrame)")
    print("Bits Per Channel: \(format.mBitsPerChannel)")
    print("Bytes Per Packet: \(format.mBytesPerPacket)")
    print("Frames Per Packet: \(format.mFramesPerPacket)")
    print("Bytes Per Frame: \(format.mBytesPerFrame)")
    print("Format ID: \(format.mFormatID)")
    print("Format Flags: \(format.mFormatFlags)")
    print("===============\n")
}

fileprivate func convert(settings: inout AudioConverterSettings) {
  var audioConverterRef: AudioConverterRef?
  
  checkError("AudioConverterNew failed") {
    AudioConverterNew(
      &settings.inputFormat,
      &settings.outputFormat,
      &audioConverterRef
    )
  }
  
  guard let audioConverterRef else {
    print("Error at \(#line): audioConvertRef is nil.")
    exit(1)
  }
  
  // 패킷 버퍼 배열 크기와 가변 비트율 데이터의 버퍼당 패킷 수 결정
  var packetsPerBuffer: UInt32 = 0
  var outputBufferSize: UInt32 = 32 * 1024 // 기본 버퍼 크기: 32KB
  var sizePerPacket: UInt32 = settings.inputFormat.mBytesPerPacket
  let bytesPerFrame: UInt32 = settings.outputFormat.mBytesPerFrame // ✅
  
  if sizePerPacket == 0 {
    // 가변 비트율 데이터의 버퍼당 패킷 결정
    var size: UInt32 = MemoryLayout.size(ofValue: sizePerPacket).toUInt32
    
    checkError("Couldn't get kAudioConverterPropertyMaximumOutputPacketSize") {
      AudioConverterGetProperty(
        audioConverterRef,
        kAudioConverterPropertyMaximumOutputPacketSize,
        &size,
        &sizePerPacket
      )
    }
    
    // 도출된 sizePerPacket이 기본 outputBufferSize보다 크면 sizePerPacket을 outputBufferSize에 할당
    if sizePerPacket > outputBufferSize {
      outputBufferSize = sizePerPacket
    }
    
    // 🔈
    // packetsPerBuffer = outputBufferSize / sizePerPacket
    packetsPerBuffer = outputBufferSize / bytesPerFrame // ✅
    
    let capacity = packetsPerBuffer.toInt * MemoryLayout<AudioStreamPacketDescription>.size
    settings.inputFilePacketDescs = UnsafeMutablePointer<AudioStreamPacketDescription>.allocate(capacity: capacity)
  } else {
    // 고정 비트율 데이터의 버퍼당 패킷 결정
    // packetsPerBuffer = outputBufferSize / sizePerPacket
    packetsPerBuffer = outputBufferSize / bytesPerFrame // ✅
  }
  
  // 오디오 변환 버퍼를 위해 메모리 할당
  let capacity = outputBufferSize.toInt * MemoryLayout<UInt8>.size
  let outputBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: capacity)
  
  var outputFilePacketPosition: UInt32 = 0
  while true {
    var convertedData = AudioBufferList(
      mNumberBuffers: 1,
      mBuffers: AudioBuffer(
        mNumberChannels: settings.inputFormat.mChannelsPerFrame,
        mDataByteSize: outputBufferSize,
        mData: outputBuffer
      )
    )
    
    var ioOutputDataPackets = packetsPerBuffer
    let status = AudioConverterFillComplexBuffer(
      audioConverterRef,
      CustomAudioConverterCallback, // callback
      &settings,
      &ioOutputDataPackets,
      &convertedData,
      settings.inputFilePacketDescs
    )
    
    if status != noErr || (ioOutputDataPackets == 0)  {
      break
    }
    
    guard let outputFileID = settings.outputFileID else {
      print("Error at \(#line): outputFileID is nil.")
      return
    }
    
    let inStartingPacket = Int64(outputFilePacketPosition / bytesPerFrame)
    // 변환된 데이터를 오디오 파일에 작성 // 🔈
    checkError("Couldn't write packets to file") {
      AudioFileWritePackets(
        outputFileID,
        false,
        ioOutputDataPackets * bytesPerFrame,
        nil, // PCM 출력 파일은 고정 비트율이므로 패킷 정보 사용 안함
        // Int64(outputFilePacketPosition / settings.outputFormat.mBytesPerPacket), // inStartingPacket: Int64,
        inStartingPacket, // ✅
        &ioOutputDataPackets,
        convertedData.mBuffers.mData!
      )
    }
    
    // 🔈
    // outputFilePacketPosition += (ioOutputDataPackets * settings.outputFormat.mBytesPerPacket)
    outputFilePacketPosition += (ioOutputDataPackets * bytesPerFrame) // ✅
  }
  
  AudioConverterDispose(audioConverterRef)
  outputBuffer.deallocate()
}


// MARK: - Converter Callback Function

fileprivate func CustomAudioConverterCallback(
  inAudioConverterRef: AudioConverterRef,
  ioDataPacketCount: UnsafeMutablePointer<UInt32>,
  ioData: UnsafeMutablePointer<AudioBufferList>,
  outDataPacketDescription: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?,
  inUserData: UnsafeMutableRawPointer?
) -> OSStatus {
  guard let inUserData else {
    print("Error at \(#line): inUserData is nil.")
    exit(1)
  }
  /*
   assumingMemoryBound(to:) 사용: UnsafeMutableRawPointer를 UnsafeMutablePointer<AudioConverterSettings>로 변환하여 특정 타입(AudioConverterSettings)의 메모리로 취급합니다.
   */
  let settingsPointer = inUserData.assumingMemoryBound(to: AudioConverterSettings.self)
  
  // AudioListBuffer는 하나의 버퍼만 가진다고 가정
  ioData.pointee.mBuffers.mData = nil
  ioData.pointee.mBuffers.mDataByteSize = 0
  
  // 입력 파일에서 읽을 수 있는 패킷의 수를 결정
  // 요청을 만족하는 충분한 패킷이 없는 경우 무엇이 남았는지 읽는다
  
  let currentPacketIndex = settingsPointer.pointee.inputFilePacketIndex + UInt64(ioDataPacketCount.pointee)
  let inputFilePacketCount = settingsPointer.pointee.inputFilePacketCount
  
  if currentPacketIndex > inputFilePacketCount {
    ioDataPacketCount.pointee = UInt32(inputFilePacketCount - settingsPointer.pointee.inputFilePacketIndex)
  }
  
  if ioDataPacketCount.pointee == 0 {
    return noErr
  }
  
  // 채우기 및 변환할 버퍼 할당
  if let sourceBuffer = settingsPointer.pointee.sourceBuffer {
    sourceBuffer.deallocate()
    // settingsPointer.pointee.sourceBuffer = nil
  }
  
  let size = ioDataPacketCount.pointee * settingsPointer.pointee.inputFilePacketMaxSize
  settingsPointer.pointee.sourceBuffer = UnsafeMutableRawPointer
    .allocate(byteCount: Int(size), alignment: MemoryLayout<UInt8>.alignment)
  
  guard let inputFileID = settingsPointer.pointee.inputFileID else {
    print("Error at \(#line): inputFileID is nil.")
    exit(1)
  }
  
  // 변환 버퍼로 패킷 읽기
  var outByteCount: UInt32 = 0
  var status = AudioFileReadPackets(
    inputFileID,
    true,
    &outByteCount,
    settingsPointer.pointee.inputFilePacketDescs,
    Int64(settingsPointer.pointee.inputFilePacketIndex),
    ioDataPacketCount,
    settingsPointer.pointee.sourceBuffer
  )
  
  // 파일의 끝에 도달하고, 1개 이상의 패킷을 받은 경우 noErr인것처럼 재설정
  if #available(macOS 10.7, *)  {
    if status == kAudioFileEndOfFileError && (ioDataPacketCount.pointee != 0) {
      status = noErr
    } else if status != noErr {
      return status
    }
  } else {
    if status == eofErr && (ioDataPacketCount.pointee != 0) {
      status = noErr
    } else if status != noErr {
      return status
    }
  }
  
  // 읽은 결과를 가지고 소스 파일 위치와 AudioBuffer 멤버를 업데이트
  settingsPointer.pointee.inputFilePacketIndex += UInt64(ioDataPacketCount.pointee)
  ioData.pointee.mBuffers.mData = settingsPointer.pointee.sourceBuffer
  ioData.pointee.mBuffers.mDataByteSize = outByteCount
  
  if let outDataPacketDescription {
    outDataPacketDescription.pointee = settingsPointer.pointee.inputFilePacketDescs
  }

  return status
}


// MARK: - Main

func AudioConverter_main() {
  var audioConvertSettings = AudioConverterSettings()
  print("[AudioConverter] 변환할 오디오 URL을 입력하세요:", terminator: " ")
  let fileURLWithPath = readLine()!
  
  // 변환을 위한 오디오 파일 열기
  let inputFileURL = URL(fileURLWithPath: fileURLWithPath.isEmpty ? "output.caf" : fileURLWithPath)
  print(inputFileURL.absoluteString)
  
  checkError("AudioFileOpenURL failed") {
    AudioFileOpenURL(
      inputFileURL as CFURL,
      .readPermission,
      0,
      &audioConvertSettings.inputFileID
    )
  }
  
  guard let inputFileID = audioConvertSettings.inputFileID else {
    print("Error at \(#line): inputFileID is nil.")
    exit(1)
  }
  
  // 입력 오디오 파일에서 ASBD 얻기
  var propSize: UInt32 = MemoryLayout.size(ofValue: audioConvertSettings.inputFormat).toUInt32
  
  checkError("Couldn't get file's data format") {
    AudioFileGetProperty(
      inputFileID,
      kAudioFilePropertyDataFormat,
      &propSize,
      &audioConvertSettings.inputFormat
    )
  }
  
  // 입력 오디오 파일에서 패킷수와 최대 패킷 크기 속성을 얻음
  
  // 파일에서 전체 패킷수를 얻음
  propSize = MemoryLayout.size(ofValue: audioConvertSettings.inputFilePacketCount).toUInt32
  checkError("Couldn't get file packet count") {
    AudioFileGetProperty(
      inputFileID,
      kAudioFilePropertyAudioDataPacketCount,
      &propSize,
      &audioConvertSettings.inputFilePacketCount
    )
  }
  
  // 가능한 최대 패킷의 크기를 얻음
  propSize = MemoryLayout.size(ofValue: audioConvertSettings.inputFilePacketMaxSize).toUInt32
  
  checkError("Couldn't get file's max packet size") {
    AudioFileGetProperty(
      inputFileID,
      kAudioFilePropertyMaximumPacketSize,
      &propSize,
      &audioConvertSettings.inputFilePacketMaxSize
    )
  }
  
  // AudioConverter_main() 함수 내에서 사용:
  printAudioDescription(audioConvertSettings.inputFormat, label: "Input Format")
  
  // 출력 ASBD 정의와 출력 오디오 파일 생성
  audioConvertSettings.outputFormat.mSampleRate = 44100.0
  audioConvertSettings.outputFormat.mFormatID = kAudioFormatLinearPCM
  audioConvertSettings.outputFormat.mFormatFlags = kAudioFormatFlagIsBigEndian |
                                                  kAudioFormatFlagIsSignedInteger |
                                                  kAudioFormatFlagIsPacked
  
  // 🔈
  audioConvertSettings.outputFormat.mBitsPerChannel = 16
  audioConvertSettings.outputFormat.mChannelsPerFrame = 2
  audioConvertSettings.outputFormat.mBytesPerPacket = 4
  audioConvertSettings.outputFormat.mBytesPerFrame = 4
  audioConvertSettings.outputFormat.mFramesPerPacket = 1
  
  // 출력 포맷 설정 후:
  printAudioDescription(audioConvertSettings.outputFormat, label: "Output Format")
  
  let inputFileName = inputFileURL.deletingPathExtension().lastPathComponent
  let outputFileURL = URL(fileURLWithPath: "Converted_\(inputFileName).aif")
  
  checkError("AudioFileCreateWithURL failed") {
    AudioFileCreateWithURL(
      outputFileURL as CFURL,
      kAudioFileAIFFType,
      &audioConvertSettings.outputFormat,
      .eraseFile,
      &audioConvertSettings.outputFileID
    )
  }
  
  print("Converting...")
  convert(settings: &audioConvertSettings)
  
  do {
    AudioFileClose(audioConvertSettings.inputFileID!)
    AudioFileClose(audioConvertSettings.outputFileID!)
    print("Finished: \(outputFileURL.absoluteString)")
  }
}
