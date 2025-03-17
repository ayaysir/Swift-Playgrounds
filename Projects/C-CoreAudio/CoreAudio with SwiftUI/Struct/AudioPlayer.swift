//
//  AudioPlayer.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/17/25.
//

import Foundation
import AudioToolbox

struct AudioPlayer {
  var streamFormat = AudioStreamBasicDescription(
    mSampleRate: 44100.0,
    mFormatID: kAudioFormatLinearPCM,
    mFormatFlags: kAudioFormatFlagIsFloat,
    mBytesPerPacket: 4,
    mFramesPerPacket: 1,
    mBytesPerFrame: 4,
    mChannelsPerFrame: 1,
    mBitsPerChannel: 32,
    mReserved: 0
  )
  
  var audioQueue: AudioQueueRef?
  var bufferSize: UInt32 = 0
  var startingFrameCount: Double = 0.0
  var currentFrequency: Double = 0.0
}
