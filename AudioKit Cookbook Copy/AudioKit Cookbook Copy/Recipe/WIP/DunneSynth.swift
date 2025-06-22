//
//  DunneSynth.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import DunneAudioKit
import AudioKitEX
import AudioKitUI
import AVFAudio
import Keyboard
import SwiftUI
import Controls
import Tonic

class DunneSynthConductor: ObservableObject, HasAudioEngine {
  let engine = AudioEngine()
  var instrument = Synth()
  
  func noteOn(pitch: Pitch, point _: CGPoint) {
    instrument.play(
      noteNumber: MIDINoteNumber(pitch.midiNoteNumber),
      velocity: 100,
      channel: 0
    )
  }
  
  func noteOff(pitch: Pitch) {
    instrument.stop(
      noteNumber: MIDINoteNumber(pitch.midiNoteNumber),
      channel: 0
    )
  }
  
  init() {
    // 출력 오디오에 리미터(Limiter) 효과를 적용, 특히 소리가 갑자기 커지는 피크(peak) 신호를 제한해서 디스토션(찢어짐)을 방지하는 용도로 사용됩니다.
    // - 특히 악기 연주(instrument)나 마이크 입력 등 볼륨 편차가 큰 신호에 유용함
    // - 설정상 즉각 반응 및 복귀를 목적으로 함
    engine.output = PeakLimiter(
      instrument,
      // 피크가 감지된 후 리미터가 작동하는 데 걸리는 시간→ 작을수록 빠르게 반응
      attackTime: 0.001,
      // 리미터 동작이 끝난 후 원래 볼륨으로 복귀하는 시간
      decayTime: 0.001,
      // 리미터에 들어가기 전 신호를 증폭 or 감쇄
      preGain: 0
    )
    
    // Remove pops
    // 노트 오프 후 사운드가 사라지기까지 걸리는 시간 (앰플리튜드) → 릴리즈가 너무 짧으면 팝 발생 가능
    instrument.releaseDuration = 0.01
    // 노트 오프 후 필터가 원래 상태로 되돌아오는 시간 → 느릴수록 부드러운 변화
    instrument.filterReleaseDuration = 10.0
    // 필터 적용 강도 → 높을수록 필터 영향 큼
    instrument.filterStrength = 40.0
    
    
    /*
     DunneSynth (Synth) 파라미터 목록:
     
     Master Volume | 1.0 | 0.0...1.0
     Pitch bend (semitones) | 0.0 | -24.0...24.0
     Vibrato Depth | 0.0 | 0.0...12.0
     Filter Cutoff | 1.0 | 0.0...1.0
     Filter Strength | 40.0 | 0.0...100.0
     Filter Resonance | -0.0 | -20.0...20.0
     Attack Duration (s) | 0.0 | 0.0...10.0
     Decay Duration (s) | 0.0 | 0.0...10.0
     Sustain Level | 1.0 | 0.0...1.0
     Release Duration (s) | 0.01 | 0.0...10.0
     Filter Attack Duration (s) | 0.0 | 0.0...10.0
     Filter Decay Duration (s) | 0.0 | 0.0...10.0
     Filter Sustain Level | 1.0 | 0.0...1.0
     Filter Release Duration (s) | 10.0 | 0.0...10.0
     */
    
    instrument.parameters.forEach {
      print("\($0.def.name) | \($0.value) | \($0.range)")
    }
  }
}

struct DunneSynthView: View {
  @StateObject var conductor = DunneSynthConductor()
  
  var body: some View {
    VStack {
      NodeOutputView(conductor.instrument)
      
      Group {
        HStack {
          ForEach(0...4, id: \.self){
            ParameterRow(param: conductor.instrument.parameters[$0])
          }
        }
        HStack {
          ForEach(5...9, id: \.self){
            ParameterRow(param: conductor.instrument.parameters[$0])
          }
        }
        HStack {
          ForEach(10...13, id: \.self){
            ParameterRow(param: conductor.instrument.parameters[$0])
          }
        }
      }
      .padding(5)
      
      CookbookKeyboard(
        noteOn: conductor.noteOn,
        noteOff: conductor.noteOff
      )
      .background(Color.teal)
    }
    .navigationTitle("Dunne Synth")
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
}

#Preview {
  DunneSynthView()
}
