//
//  AppleReverb.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import AVFoundation
import DunneAudioKit
import SoundpipeAudioKit
import SwiftUI

extension AVAudioUnitReverbPreset: @retroactive CaseIterable, @retroactive Identifiable {
  public var id: String {
    "\(rawValue)_\(name)"
  }
}

class ReverbConductor: BasicEffectConductor<Reverb> {
  init() {
    super.init(source: .drums) { input in
      Reverb(input) // from AudioKit: AudioKit version of Apple’s Reverb Audio Unit
    }
  }
}
struct ReverbView: View {
  @StateObject private var conductor = ReverbConductor()
  @State private var currentPreset: AVAudioUnitReverbPreset? = .init(rawValue: 0)
  
  let columnsCount: Int = 2
  let columnsMargin: CGFloat = 10
  
  // 화면을 그리드형식으로 꽉채워줌
  var columns: [GridItem] {
    (1...columnsCount).map { _ in GridItem(.flexible(), spacing: columnsMargin) }
  }
  
  var cellHeight: CGFloat {
    let screenWidth: CGFloat

    #if os(iOS)
    screenWidth = UIScreen.main.bounds.width
    #elseif os(macOS)
    screenWidth = NSScreen.main?.frame.width ?? 800 // macOS 기본값 fallback
    #endif

    return screenWidth / CGFloat(columnsCount) - columnsMargin - 30
  }
  
  var body: some View {
    VStack(spacing: 30) {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      LazyVGrid(columns: columns, spacing: columnsMargin) {
        ForEach(AVAudioUnitReverbPreset.allCases) { preset in
          Button {
            conductor.effect.loadFactoryPreset(preset)
            currentPreset = preset
          } label: {
            Text(preset.name)
              .font(.caption)
              .frame(width: cellHeight, height: CGFloat(10))
          }
          .tagStyle(currentPreset == preset ? .prominent : .bordered)
          .tint(Color.green)
        }
      }
      Spacer()
      NodeOutputView(conductor.effect)
    }
    .padding()
    .navigationTitle("Apple Reverb")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  ReverbView()
}
