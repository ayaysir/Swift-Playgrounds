//
//  Cookbook.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/29/25.
//

import Foundation
import AVFoundation

class Cookbook {
  static var sourceBuffer: AVAudioPCMBuffer {
    let url = Bundle.main.resourceURL?.appending(path: "Samples/beat.aiff")
    let file = try! AVAudioFile(forReading: url!)
    return try! AVAudioPCMBuffer(file: file)!
  }
}
