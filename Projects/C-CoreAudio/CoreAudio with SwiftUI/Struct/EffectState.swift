//
//  EffectState.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/17/25.
//

import Foundation
import AudioToolbox

struct EffectState {
  var remoteIOUnit: AudioUnit?
  var asbd: AudioStreamBasicDescription = .init()
  var sineFrequency: Float = 0
  var sinePhase: Float = 0
}
