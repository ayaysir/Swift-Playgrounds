//
//  TestAudioURLs.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/18/25.
//

import Foundation

enum TestAudioURLs: String, CaseIterable {
  case beat = "beat.aiff",
       counting = "Counting.mp3",
       guitar = "Guitar.mp3",
       bassDrum = "bass_drum_C1.wav",
       clap = "clap_D#1.wav",
       snare = "snare_D1.wav",
       lowTom = "lo_tom_F1.wav",
       midTom = "mid_tom_B1.wav",
       highTom = "hi_tom_D2.wav"
  
  func url() -> URL? {
    return Bundle.main.url(forResource: "Samples/\(rawValue)", withExtension: "")
  }
}
