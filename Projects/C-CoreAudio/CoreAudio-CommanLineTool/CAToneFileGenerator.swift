//
//  CAToneFileGenerator.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/26/25.
//

import Foundation
import AudioToolbox

func CAToneFileGenerator() {
  enum Wave: String, CaseIterable {
    case Sine, Square, Sawtooth
  }
  
  let SAMPLE_RATE: Float64 = 44100.0
  let DURATION = 5.0
  
  let SHRT_MAX_DBL = Double(Int16.max)
  
  print("Enter Hz:", terminator: " ")
  
  let hz = readLine()!.split(separator: " ").map { Double($0)! }.first!
  guard hz > 0 else {
    print("Error: hz is less than 0.")
    return
  }
  
  print("Generating %f hz tone...", hz)
  
  let currentDirPath = FileManager.default.currentDirectoryPath
  print("currentDirPath:", currentDirPath)
  
  Wave.allCases.forEach { wave in
    let url = URL(fileURLWithPath: currentDirPath)
      .appendingPathComponent(.init(format: "%0.3f-\(wave).aif", hz))
    
    // 형식 준비
    // AudioStreamBasicDescription: 오디오 스트림의 특성을 정의
    // 채널수, 형식, 비트율 등
    var asbd = AudioStreamBasicDescription()
    asbd.mSampleRate = SAMPLE_RATE
    asbd.mFormatID = kAudioFormatLinearPCM
    asbd.mFormatFlags = kAudioFormatFlagIsBigEndian |
                        kAudioFormatFlagIsSignedInteger |
                        kAudioFormatFlagIsPacked // 샘플 값이 각 바이트에 가용한 모든 비트를 사용
    asbd.mBitsPerChannel = 16
    asbd.mChannelsPerFrame = 1
    asbd.mFramesPerPacket = 1
    // mBytesPerFrame 계산: (mChannelsPerFrame * mBitsPerChannel) / 8
    // 예) (16 * 1) / 8 = 2
    asbd.mBytesPerFrame = (asbd.mChannelsPerFrame * asbd.mBitsPerChannel) / 8
    
    // mBytesPerPacket은 압축되지 않은 PCM 데이터의 경우 mBytesPerFrame과 동일
    asbd.mBytesPerPacket = asbd.mBytesPerFrame
    
    /*
     BigEndian: 바이트/워드의 높은 비트가 낮은 비트보다 숫자적으로 중요
     LittleEndian: 바이트/워드의 낮은 비트가 높은 비트보다 숫자적으로 중요
     */
    
    // 파일 설정
    var audioFileID: AudioFileID?
    var audioErr: OSStatus = noErr
    
    audioErr = AudioFileCreateWithURL(
      url as CFURL,
      kAudioFileAIFFType, // AIFF는 BigEndian만 지원
      &asbd,
      .eraseFile,
      &audioFileID
    )
    
    guard audioErr == noErr else {
      print("Error at \(#line): \(audioErr.debugDescription)")
      return
    }
    
    // 샘플 작성 시작
    let maxSampleCount = Int64(SAMPLE_RATE * DURATION)
    var sampleCount: Int64 = 0
    var bytesToWrite: UInt32 = 2 // 포인터로 지정해야 하며 값을 직접 파라미터로 넣을 수는 없다.
    // wavelengthInSamples: 하나의 주기가 몇 개의 샘플로 구성되는지를 나타내는 값
    // 예) 44100 / 440 = 100.23
    let wavelengthInSamples = SAMPLE_RATE / hz
    
    while sampleCount < maxSampleCount {
      for i in 0..<Int(wavelengthInSamples) {
        var sample: Int16
        switch wave {
        case .Sine:
          let normalizedPhaseAngle = Double(i) / wavelengthInSamples
          // 위상각에 2pi를 곱해 사인 함수를 위한 라디안으로 변경, ~1.0 - 1.0 을 반환
          let sineValue = sin(2 * .pi * normalizedPhaseAngle)
          sample = Int16(sineValue * SHRT_MAX_DBL).toBigEndian
        case .Square:
          // 파장의 첫 번째 반에 최대값, 나머지 반에 최소값
          sample =  i < Int(wavelengthInSamples) / 2 ? .max.toBigEndian : .min.toBigEndian
        case .Sawtooth:
          let normalized = Double(i) / wavelengthInSamples // 0 ~ 1로 평탄화
          sample = Int16((normalized * 2.0 * SHRT_MAX_DBL) - SHRT_MAX_DBL).toBigEndian
          // normalized를 2배 후 최대값을 SHRT_MAX_DBL 까지로 제한
        }
        
        /*
         .toBigEndian: Intel/ARM 은 기본적으로 LittleEndian이므로, 명시적으로 BigEndian으로 변경할 필요가 있다.
         
         * 파형 종류
         - Square: 두 값 사이를 변경
         - Sawtooth: 파형의 길이에서 최소값 -> 최대값으로 선형 증가, 다음 파형에서 초기화 후 반복
         - Sine: 삼각함수 Sine에 부합, Harmonic Motion을 닮았기 때문에 현악기 진동 같은 자연스러움
         */
        
        guard let audioFileID else {
          print(#line, "Error: AudioFileID is nil.")
          return
        }
        
        audioErr = AudioFileWriteBytes(
          audioFileID, // inAudioFile
          false, // inUseCache: 캐싱 여부
          sampleCount * 2, // inStartingByte
          &bytesToWrite, // ioNumBytes
          &sample // inBuffer
        )
        
        guard audioErr == noErr else {
          print("Error at \(#line): \(audioErr.debugDescription)")
          return
        }
        
        sampleCount += 1  // 새로운 데이터를 증가된 위치에 작성
      }
    }
    
    guard let audioFileID else {
      print("Error: audioFileID is nil.")
      return
    }
    
    audioErr = AudioFileClose(audioFileID)
    
    guard audioErr == noErr else {
      print("Error at \(#line): \(audioErr.debugDescription)")
      return
    }
    
    print("Wrote \(sampleCount) samples.")
  }
}


