//
//  GlobalSource.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/30/25.
//

import Foundation

enum GlobalSource: CaseIterable, Identifiable {
  var id: String {
    "\(name)__\(fileName)"
  }
  
  static var allCases: [GlobalSource] = [
    .baseSynth, .drums, .femaleVoice, .guitar, .maleVoice, .piano, .strings, .synth
  ]
  
  case baseSynth
  case drums
  case femaleVoice
  case guitar
  case maleVoice
  case piano
  case strings
  case synth
  case custom(URL)
  
  var name: String {
    switch self {
    case .baseSynth:
      "Bass Synth"
    case .drums:
      "Drums"
    case .femaleVoice:
      "Female Voice"
    case .guitar:
      "Guitar"
    case .maleVoice:
      "Male Voice"
    case .piano:
      "Piano"
    case .strings:
      "Strings"
    case .synth:
      "Synth"
    case .custom(let url):
      url.deletingPathExtension().lastPathComponent
    }
  }
  
  var filePath: String {
    guard case .custom(let url) = self else {
      return "Samples/\(fileName)"
    }
    
    return url.absoluteString
  }
  
  var fileName: String {
    switch self {
    case .baseSynth:
      "Bass Synth.mp3"
    case .drums:
      "beat.aiff"
    case .femaleVoice:
      "alphabet.mp3"
    case .guitar:
      "Guitar.mp3"
    case .maleVoice:
      "Counting.mp3"
    case .piano:
      "Piano.mp3"
    case .strings:
      "Strings.mp3"
    case .synth:
      "Synth.mp3"
    case .custom(let url):
      url.lastPathComponent
    }
  }
}
