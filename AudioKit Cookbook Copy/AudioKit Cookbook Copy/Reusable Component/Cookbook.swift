//
//  Cookbook.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/29/25.
//

import Foundation
import AVFoundation
import AudioKit

// 사전 구조 (이름 → 파일명)
public let globalSourceDict: [String: String] = [
  "Bass Synth": "Bass Synth.mp3",
  "Drums": "beat.aiff",
  "Female Voice": "alphabet.mp3",
  "Guitar": "Guitar.mp3",
  "Male Voice": "Counting.mp3",
  "Piano": "Piano.mp3",
  "Strings": "Strings.mp3",
  "Synth": "Synth.mp3",
]

// 순서를 유지할 키 목록
public let globalSourceKeys: [String] = [
  "Bass Synth",
  "Drums",
  "Female Voice",
  "Guitar",
  "Male Voice",
  "Piano",
  "Strings",
  "Synth"
]

// 배열 형태
public let globalSourceArray: [[String]] = globalSourceKeys.map { key in
  [key, globalSourceDict[key] ?? key]
}

class Cookbook {
  static var sourceBuffer: AVAudioPCMBuffer {
    sourceBuffer(source: GlobalSource.drums)
  }
  
  static func sourceBuffer(source: GlobalSource) -> AVAudioPCMBuffer {
    let url = Bundle.main.resourceURL?.appending(path: source.filePath)
    let file = try! AVAudioFile(forReading: url!)
    return try! AVAudioPCMBuffer(file: file)!
  }
  
  static func fullLengthBuffer(url: URL) -> AVAudioPCMBuffer? {
    guard let file = try? AVAudioFile(forReading: url) else {
      Log("failed to read AVAudioFile", url)
      return nil
    }

    guard let buffer = AVAudioPCMBuffer(
      pcmFormat: file.processingFormat,
      frameCapacity: AVAudioFrameCount(file.length)
    ) else {
      Log("failed to create AVAudioPCMBuffer")
      return nil
    }

    do {
      try file.read(into: buffer)
    } catch {
      Log("failed to read into buffer: \(error.localizedDescription)")
      return nil
    }
    
    return buffer
  }
}
