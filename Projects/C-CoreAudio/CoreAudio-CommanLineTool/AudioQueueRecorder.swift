//
//  AudioQueueRecorder.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/27/25.
//

import Foundation
import AudioToolbox

// MARK: - User Data Struct
fileprivate struct Recorder {
  var recordFileID: AudioFileID?
  var recordPacket: Int64 = 0
  var isRunning: Bool = false
}

// MARK: - Utility Functions
fileprivate func checkError(_ message: String, callback: () -> (OSStatus)) {
  let status = callback()
  guard status == noErr else {
    print("Error: \(message), \(status.debugDescription)")
    exit(1)
  }
}

/// 현재 오디오 입력 장치의 outSampleRate 읽기
fileprivate func getDefaultInputDeviceSampleRate(_ outSampleRate: inout Float64) -> OSStatus {
  var status = OSStatus()
  var deviceID: AudioDeviceID = 0
  
  var propertyAddress = AudioObjectPropertyAddress()
  
  propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice
  propertyAddress.mScope = kAudioObjectPropertyScopeGlobal
  propertyAddress.mElement = 0
  
  var propertySize = MemoryLayout<AudioDeviceID>.size.toUInt32
  
  status = AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject),
    &propertyAddress,
    0,
    nil,
    &propertySize,
    &deviceID
  )
  
  guard status == noErr else {
    return status
  }
  
  propertyAddress.mSelector = kAudioDevicePropertyNominalSampleRate
  propertyAddress.mScope = kAudioObjectPropertyScopeGlobal
  propertyAddress.mElement = 0
  propertySize = MemoryLayout<Float64>.size.toUInt32
  
  // 'AudioHardwareServiceGetPropertyData' was deprecated in macOS 10.11: no longer supported
  AudioObjectGetPropertyData(
    deviceID,
    &propertyAddress,
    0,
    nil,
    &propertySize,
    &outSampleRate // outData
  )
  
  return status
  
  /*
   속성을 얻는 것은 요청할 오디오객체 kAudioObjectSystemObject d와 속성, scope & element까지 포함한
   AudioObjectPropertyAddress를 명시하도록 요구한다. 하드웨어의 일반 속성을 쿼리하기 위해 전역 스콥과
   0의 값을 가지는 마스터 엘리먼트를 요청할 수 있다.
   */
}

/// 오디오 큐(`queue`)의 매직 쿠키를 오디오 파일(`audioFileID`)에 복사
fileprivate func copyEncoderCookieToFile(
  _ queue: AudioQueueRef,
  _ audioFileID: AudioFileID
) -> OSStatus {
  var status = OSStatus()
  var propertySize: UInt32 = 0
  
  status = AudioQueueGetPropertySize(
    queue,
    kAudioConverterCompressionMagicCookie,
    &propertySize
  )
  
  guard status == noErr && propertySize > 0 else {
    return status
  }
  
  let magicCookie = UnsafeMutablePointer<UInt8>.allocate(capacity: propertySize.toInt)
  status = AudioQueueGetProperty(
    queue,
    kAudioQueueProperty_MagicCookie,
    magicCookie,
    &propertySize
  )
  
  guard status == noErr else {
    return status
  }
  
  status = AudioFileSetProperty(
    audioFileID,
    kAudioFilePropertyMagicCookieData,
    propertySize,
    magicCookie
  )
  
  free(magicCookie)
  return status
}

/// 특정 타입의 오디오에서 일정 기간 보관하기 위해 필요한 버퍼의 크기를 계산
fileprivate func computeRecordBufferSize(
  _ format: AudioStreamBasicDescription,
  _ queue: AudioQueueRef,
  _ seconds: Float
) -> Int {
  var packets, frames, bytes: Int
  // 프레임 = 샘플율 * 버퍼기간
  frames = Int(ceil(Float64(seconds) * format.mSampleRate))
  
  if format.mBytesPerFrame > 0 {
    bytes = frames * Int(format.mBytesPerFrame)
  } else {
    // ASBD.mBytesPerFrame가 0인 경우 패킷 수준에서 작업
    
    var maxPacketSize: UInt32 = 0
    
    if format.mBytesPerFrame > 0 {
      // 고정된 패킷 크기
      maxPacketSize = format.mBytesPerFrame
    } else {
      // 가능한 가장 큰 패킷 크기 획득
      var propertySize = MemoryLayout.size(ofValue: maxPacketSize).toUInt32
      checkError("Couldn't get queue's maximum output packet size.") {
        AudioQueueGetProperty(
          queue,
          kAudioConverterPropertyMaximumOutputPacketSize,
          &maxPacketSize,
          &propertySize
        )
      }
    }
    
    if format.mFramesPerPacket > 0 {
      // 패킷 수 = 프레임 / mFramesPerPacket
      packets = frames / Int(format.mFramesPerPacket)
    } else {
      // 최악의 경우: 패킷에 하나의 프레임
      packets = frames
    }
    
    // 오류 검사
    if packets == 0 {
      packets = 1
    }
    
    bytes = packets * Int(maxPacketSize)
  }
  
  return bytes
}

// MARK: - Record Callback Function

// AudioQueueInputCallback 타입
func customAudioQueueInputCallback(
  inUserData: UnsafeMutableRawPointer?,
  inQueue: AudioQueueRef,
  inBuffer: AudioQueueBufferRef,
  inStartTime: UnsafePointer<AudioTimeStamp>,
  inNumPackets: UInt32,
  inPacketDesc: UnsafePointer<AudioStreamPacketDescription>?
) {
  guard let inUserData else {
    print("\(#function) Error: inUserData is nil.")
    exit(1)
  }
  /*
   ... void *inUserData...
   Recorder *recorder = (Recorder *) inUserData;
   
   assumingMemoryBound(to:) 사용: UnsafeMutableRawPointer를 UnsafeMutablePointer<Recorder>로 변환하여 특정 타입(Recorder)의 메모리로 취급합니다.
   .pointee 사용: UnsafeMutablePointer<Recorder>에서 실제 Recorder 인스턴스를 가져옵니다.
   */
  let recorderPointer = inUserData.assumingMemoryBound(to: Recorder.self)
  
  guard let recordFileID = recorderPointer.pointee.recordFileID else {
    print("\(#function) Error: recorder is not initialized correctly.")
    exit(1)
  }
  
  var outNumPackets = inNumPackets
  
  if inNumPackets > 0 {
    // 파일을 패킷에 작성
    checkError("AudioFileWritePackets failed.") {
      AudioFileWritePackets(
        recordFileID, // inAudioFile
        false, // inUseCache
        inBuffer.pointee.mAudioDataByteSize, // inNumBytes: 작성할 데이터 버퍼의 크기
        inPacketDesc, // inPacketDescriptions: 패킷 설명 구조체
        recorderPointer.pointee.recordPacket, // inStartingPacket: Int64, 작성할 파일의 어떤 패킷의 인덱스
        &outNumPackets, // ioNumPackets: 작성할 패킷의 수
        inBuffer.pointee.mAudioData // inBuffer
      )
    }
    
    // 패킷 인덱스를 증가: 반복적으로 0에 쓰지 않음
    // recorder를 inout으로 직접 수정 가능하ㄷ록 recorderPointer.pointee를 사용
    recorderPointer.pointee.recordPacket += Int64(outNumPackets)
  }
  
  // 사용된 버퍼를 다시 큐에 넣음
  if recorderPointer.pointee.isRunning {
    checkError("AudioQueueEnqueBuffer failed.") {
      AudioQueueEnqueueBuffer(
        inQueue,
        inBuffer,
        0,
        nil
      )
    }
  }
}

// MARK: - Main

fileprivate let kNumberRecordBuffers = 3

func AudioQueueRecorder_Main() {
  // 형식 설정
  var recorder = Recorder()
  var recordFormat = AudioStreamBasicDescription()
  recordFormat.mFormatID = kAudioFormatMPEG4AAC
  recordFormat.mChannelsPerFrame = 2
  
  checkError("getDefaultInputDeviceSampleRate failed.") {
    // 입력 기기에서 recordFormat.mSmapleRate를 불러온다.
    getDefaultInputDeviceSampleRate(&recordFormat.mSampleRate)
  }
  
  print("mSampleRate: \(recordFormat.mSampleRate)")
  
  var propSize = MemoryLayout.size(ofValue: recordFormat).toUInt32
  checkError("AudioFormatGetProperty failed") {
    // 개발자가 알 수 없는 ASBD의 일부 속성을 AFGP 를 통해 불러온다.
    AudioFormatGetProperty(
      kAudioFormatProperty_FormatInfo,
      0,
      nil,
      &propSize,
      &recordFormat
    )
  }
  
  // 큐 설정
  var queue: AudioQueueRef?
  checkError("AudioQueueNewInput failed") {
    AudioQueueNewInput(
      &recordFormat, // inFormat
      customAudioQueueInputCallback, // inCallbackProc
      &recorder, // inUserData
      nil, // inCallbackRunLoop
      nil, // inCallbackRunLoopMode
      0, // inFlags
      &queue // outAQ
    )
  }
  
  var size = MemoryLayout.size(ofValue: recordFormat).toUInt32
  guard let queue else {
    print("Error at \(#line): queue is nil.")
    return
  }
  
  checkError("Couldn't get queue's format.") {
    // 오디오 큐에서 채워진 ASBD를 추출
    AudioQueueGetProperty(
      queue,
      kAudioConverterCurrentOutputStreamDescription,
      &recordFormat,
      &size
    )
  }
  
  // 파일 설정: 출력을 위한 오디오 파일 생성
  let fileURL = URL(fileURLWithPath: "output.caf", isDirectory: false)

  checkError("AudioFileCreateWithURL failed.") {
    AudioFileCreateWithURL(
      fileURL as CFURL,
      kAudioFileCAFType,
      &recordFormat,
      .eraseFile,
      &recorder.recordFileID
    )
  }
  
  guard let recordFileID = recorder.recordFileID else {
    print("Error at \(#line): recorder.recordFileID is nil.")
    return
  }
  
  // 4.11
  checkError("copyEncoderCookieToFile(#\(#line)) failed.") {
    // 매직 쿠키 처리
    copyEncoderCookieToFile(queue, recordFileID)
  }
  
  // 기타 설정
  
  // 녹음 크기를 계산하기 위한 computeRecordBufferSize 함수 호출
  // int bufferByteSize = ComputeRecordBufferSize(&recordFormat, queue, 0.5);
  let bufferByteSize: UInt32 = computeRecordBufferSize(
    recordFormat,
    queue,
    0.5
  ).toUInt32
  
  // 버퍼 할당과 큐에 삽입
  for _ in 0..<kNumberRecordBuffers {
    var buffer: AudioQueueBufferRef?
    
    checkError("AudioQueueAllocateBuffer failed.") {
      AudioQueueAllocateBuffer(
        queue,
        bufferByteSize,
        &buffer
      )
    }
    
    checkError("AudioQueueEnqueBuffer failed.") {
      AudioQueueEnqueueBuffer(
        queue,
        buffer!,
        0,
        nil
      )
    }
  }
  
  // 오디오 큐 시작
  recorder.isRunning = true
  checkError("AudioQueueStart failed.") {
    AudioQueueStart(queue, nil)
  }
  
  print("Recording.. press <return> to stop.", terminator: "")
  _ = readLine()
  
  // 오디오 큐 중지
  
  print("Recoding done.")
  recorder.isRunning = false
  checkError("AudioQueueStop failed.") {
    AudioQueueStop(queue, true)
  }
  // 4.17 : CopyEncoderCookieToFile(queue, recorder.recordFile);
  checkError("copyEncoderCookieToFile(#\(#line)) failed.") {
    copyEncoderCookieToFile(queue, recordFileID)
  }
  
  AudioQueueDispose(queue, true)
  AudioFileClose(recorder.recordFileID!)
}

/*
 Xcode mac 앱에서 마이크 권한 획득하는 방법:
 1. Select your project in the Project Navigator
 2. Select the Target you want to add permissions to
 3. Go to "Signing & Capabilities"
 4. In the App Sandbox section, Hardware group, select the checkbox "Audio Input"
 */
