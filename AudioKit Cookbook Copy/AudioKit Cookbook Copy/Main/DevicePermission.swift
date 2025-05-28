//
//  DevicePermission.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/10/25.
//

import AVFoundation

func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
  AVAudioApplication.requestRecordPermission { granted in
    DispatchQueue.main.async {
      completion(granted)
    }
  }
}
