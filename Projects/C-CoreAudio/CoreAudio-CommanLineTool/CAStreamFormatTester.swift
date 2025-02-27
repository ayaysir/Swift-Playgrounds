//
//  CAStreamFormatTester.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/27/25.
//

import Foundation
import AudioToolbox

func CAStreamFormatTester() {
  CAStreamFormatTesterScenario.allCases.forEach { scenario in
    print("========= \(scenario) =========")
    
    // kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat 속성을 얻기 위한 구조체
    var fileTypeAndFormat = AudioFileTypeAndFormatID()
    fileTypeAndFormat.mFileType = scenario.fileType
    fileTypeAndFormat.mFormatID = scenario.formatID
    
    var audioErr = noErr
    var infoSize: UInt32 = 0
    
    // 속성의 크기를 알아내 infoSize에 저장
    audioErr = AudioFileGetGlobalInfoSize(
      kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
      MemoryLayout.size(ofValue: fileTypeAndFormat).toUInt32,
      &fileTypeAndFormat,
      &infoSize
    )
    
    guard audioErr == noErr else {
      print("Error at #\(#line):", audioErr.debugDescription)
      return
    }
    
    // infoSize 크기를 메모리 할당 (Memory ALLOCation)
    // AudioStreamBasicDescription *asbds = malloc (infoSize);
    let asbds = UnsafeMutablePointer<AudioStreamBasicDescription>
      .allocate(capacity: infoSize.toInt / MemoryLayout<AudioStreamBasicDescription>.size)
    
    audioErr = AudioFileGetGlobalInfo(
      kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat,
      MemoryLayout.size(ofValue: fileTypeAndFormat).toUInt32,
      &fileTypeAndFormat,
      &infoSize,
      asbds
    )
    
    guard audioErr == noErr else {
      print("Error at #\(#line):", audioErr.debugDescription)
      return
    }
    
    // 배열 길이 계산: ASBDs의 메모리 크기에서 infoSize를 나눔
    let asbdCount = infoSize.toInt / MemoryLayout<AudioStreamBasicDescription>.size
    
    for i in 0..<asbdCount {
      var format4cc = asbds[i].mFormatID.bigEndian
      
      withUnsafeBytes(of: &format4cc) { rawPtr in
        let charPtr = rawPtr.bindMemory(to: CChar.self).baseAddress!
        print(
          String(
            format: "%d: mFormatId: %4.4s, mFormatFlags: %d, mBitsPerChannel: %d",
            i,
            charPtr,
            asbds[i].mFormatFlags,
            asbds[i].mBitsPerChannel
          )
        )
      }
    }
    
    // malloc 해제
    free(asbds)
    print()
  }
}

enum CAStreamFormatTesterScenario: Int, CaseIterable {
  case AIFF_LinearPCM, WAVE_LinearPCM, CAF_LinearPCM, CAF_AAC, MP3_AAC
  
  var fileType: AudioFileTypeID {
    return switch self {
    case .AIFF_LinearPCM:
      kAudioFileAIFFType
    case .WAVE_LinearPCM:
      kAudioFileWAVEType
    case .CAF_LinearPCM, .CAF_AAC:
      kAudioFileCAFType
    case .MP3_AAC:
      kAudioFileMP3Type
    }
  }
  
  var formatID: AudioFormatID {
    return switch self {
    case .AIFF_LinearPCM, .WAVE_LinearPCM, .CAF_LinearPCM:
      kAudioFormatLinearPCM
    case .CAF_AAC, .MP3_AAC:
      kAudioFormatMPEG4AAC
    }
  }
}

/*
 ========= AIFF_LinearPCM =========
 0: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 8
 1: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 16
 2: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 24
 3: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 32

 ========= WAVE_LinearPCM =========
 0: mFormatId: lpcm, mFormatFlags: 8, mBitsPerChannel: 8
 1: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 16
 2: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 24
 3: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 32
 4: mFormatId: lpcm, mFormatFlags: 9, mBitsPerChannel: 32
 5: mFormatId: lpcm, mFormatFlags: 9, mBitsPerChannel: 64

 ========= CAF_LinearPCM =========
 0: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 8
 1: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 16
 2: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 24
 3: mFormatId: lpcm, mFormatFlags: 14, mBitsPerChannel: 32
 4: mFormatId: lpcm, mFormatFlags: 11, mBitsPerChannel: 32
 5: mFormatId: lpcm, mFormatFlags: 11, mBitsPerChannel: 64
 6: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 16
 7: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 24
 8: mFormatId: lpcm, mFormatFlags: 12, mBitsPerChannel: 32
 9: mFormatId: lpcm, mFormatFlags: 9, mBitsPerChannel: 32
 10: mFormatId: lpcm, mFormatFlags: 9, mBitsPerChannel: 64

 ========= CAF_AAC =========
 0: mFormatId: aac , mFormatFlags: 0, mBitsPerChannel: 0

 ========= MP3_AAC =========
 Error at #32: 1718449215 (fmt?)
 */


/*
 format4cc(4 Character Code)를 문자열로 출력
 %4.4s는 4바이트(FourCC) 코드를 문자열로 출력하는 형식입니다.
 - 최소 4자리를 출력, 최대 4자리를 출력
 
 1. withUnsafeBytes(of: &format4cc)
 •  format4cc가 4바이트(32비트) 크기의 UInt32 값이면,
withUnsafeBytes(of: &format4cc)를 사용하면 해당 변수의 원시 바이트(메모리 주소)를 직접 접근할 수 있는 포인터를 얻습니다.
 •  rawPtr은 UnsafeRawBufferPointer 타입의 값입니다. (즉, 어떤 타입이든 담을 수 있는 바이트 단위의 포인터)
 
 2. bindMemory(to: CChar.self)
 •  bindMemory(to: CChar.self)는 메모리를 특정 타입(CChar)으로 변환하는 역할을 합니다.
 •  CChar는 C 언어의 char(1바이트 정수) 타입과 같습니다.
 •  format4cc는 UInt32라서 원래 4바이트(32비트)의 정수지만, 이를 C 스타일 char * 포인터로 접근할 수 있도록 변환하는 과정입니다.
 
 3. baseAddress!
 •  .baseAddress는 변환된 메모리의 첫 번째 주소(포인터)를 가져옵니다.
 •  **!(강제 언래핑)**을 사용한 이유:
baseAddress는 옵셔널(UnsafePointer<CChar>?) 타입이므로, 강제 언래핑하여 UnsafePointer<CChar>로 변환합니다.
 */
