//
//  ZitaReverb.swift
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

class ZitaReverbConductor: BasicEffectConductor<ZitaReverb> {
  init() {
    super.init(source: .drums) { input in
      ZitaReverb(input) // from SoundpipeAudioKit
    }
  }
  
  /*
   ZitaReverb의 파라미터 목록:
   
   PreDelay | 60.0 | 10.0...100.0
   Crossover frequency | 200.0 | 50.0...1000.0
   Low release time | 3.0 | 1.0...8.0
   Mid Release Time | 2.0 | 1.0...8.0
   Damping Frequency | 6000.0 | 1500.0...47040.0
   EQ Frequency 1 | 315.0 | 40.0...2500.0
   EQ Level 1 | 0.0 | -15.0...15.0
   EQ Frequency 2 | 1000.0 | 160.0...1000.0
   EQ Level 2 | 0.0 | -15.0...15.0
   Dry Wet Mix | 1.0 | 0.0...1.0
   */
}

struct ZitaReverbView: View {
  @StateObject private var conductor = ZitaReverbConductor()
  
  let columnsCount: Int = 5
  let columnsMargin: CGFloat = 10
  
  // 화면을 그리드형식으로 꽉채워줌
  var columns: [GridItem] {
    (1...columnsCount).map { _ in GridItem(.flexible(), spacing: columnsMargin) }
  }
  
  var body: some View {
    VStack {
      PlayerControlsII(conductor: conductor, source: conductor.defaultSource)
      LazyVGrid(columns: columns, spacing: 10) {
        ForEach(conductor.effect.parameters) { parameter in
          ParameterRow(param: parameter)
        }
      }
      
      Spacer()
      
      NodeOutputView(conductor.player)
        .frame(height: 100)
      NodeOutputView(conductor.effect)
        .frame(height: 100)
      
      Spacer()
    }
    .padding()
    .navigationTitle("Zita Reverb")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  ZitaReverbView()
}
