//
//  ControlsView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import AudioKit
import Controls
import Keyboard
import SwiftUI
import Tonic

struct ControlsView: View {
  @StateObject var conductor = InstrumentSFZConductor()
  
  @State var pitchBend: Float = 0.5
  @State var modulation: Float = 0
  @State var radius: Float = 0
  @State var angle: Float = 0
  @State var x: Float = 0.5
  @State var y: Float = 0.5
  
  @State var octaveRange = 1
  @State var layoutType = 0
  
  @State var attack: Float = 33
  @State var decay: Float = 66
  @State var volume: Float = 0
  @State var pan: Float = 0
  
  @State var smallKnobValue: Float = 0.5
  
  @State var ribbon: Float = 0
  
  @State var lowestNote = 48
  var hightestNote: Int {
    (octaveRange + 1) * 12 + lowestNote
  }
  
  @State var controlStatusText = ""
  
  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 10) {
        VStack {
          Spacer()
          HStack {
            Joystick(radius: $radius, angle: $angle)
              .backgroundColor(.gray.opacity(0.5))
              .foregroundColor(.teal.opacity(0.5))
              .squareFrame(140) // 원형 스틱을 감싸는 가로세로 프레임 크기
            XYPad(x: $x, y: $y)
              .cornerRadius(20) // CornerRadius를 사용해야 내부 요소까지 코너가 적용됨
              .indicatorSize(CGSize(width: 15, height: 15))
              .squareFrame(140)
            
            StyledArcKnob("Attack", value: $attack)
            StyledArcKnob("Decay", value: $decay)
            StyledArcKnob("VoDep", value: $pan)
            StyledArcKnob("Vol", value: $volume)
          }
          .frame(height: 140)
          
          HStack {
            Text(controlStatusText)
              .font(.system(size: 12))
              .monospaced()
              .frame(width: 80, alignment: .leading)
            Text("Octaves:")
            IndexedSlider(index: $octaveRange, labels: ["1", "2", "3"])
              .backgroundColor(.gray.opacity(0.5))
              .foregroundColor(.white.opacity(0.5))
              .cornerRadius(10)
            
            Text("Detune:")
            SmallKnob(value: $smallKnobValue)
              .backgroundColor(.gray.opacity(0.5))
              .foregroundColor(.white.opacity(0.5))
            
            Text("Layout:")
            IndexedSlider(index: $layoutType, labels: ["Piano", "Isomorphic", "Guitar"])
              .backgroundColor(.gray.opacity(0.5))
              .foregroundColor(.white.opacity(0.5))
              .cornerRadius(10)
          }
          .frame(height: 30)
          
          Ribbon(position: $ribbon)
            .cornerRadius(5)
            .frame(height: 15)
          
          HStack {
            PitchWheel(value: $pitchBend)
              .cornerRadius(10)
              .frame(width: 50)
            ModWheel(value: $modulation)
                .cornerRadius(10)
                .frame(width: 50)
            Keyboard(
              layout: layout,
              noteOn: conductor.noteOn,
              noteOff: conductor.noteOff
            )
          }
        }
      }
    }
    .navigationTitle("Controls Demo")
    .onAppear {
      forceOrientation(to: .landscape)
      conductor.start()
    }
    .onDisappear {
      forceOrientation(to: .all)
      conductor.stop()
    }
    .onChange(of: pitchBend) {
      setParameter(pitchBend, index: 1)
    }
    .onChange(of: modulation) {
      setParameter(modulation, index: 2)
    }
    .onChange(of: volume) {
      setParameter(volume / 100, index: 0)
    }
    .onChange(of: attack) {
      setParameter(attack / 100, index: 10)
    }
    .onChange(of: decay) {
      setParameter(decay / 100, index: 12)
    }
    .onChange(of: pan) {
      conductor.instrument.voiceVibratoDepth = pan / 12
    }
    .onChange(of: radius) {
      changeJoyStickText()
    }
    .onChange(of: angle) {
      changeJoyStickText()
    }
    .onChange(of: x) {
      changeXYText()
    }
    .onChange(of: y) {
      changeXYText()
    }
  }
  
  func changeJoyStickText() {
    controlStatusText = String(
      format: """
             Rad %.2f
             Ang %.2f
             """,
      radius,
      angle
    )
    
    if radius == 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        withAnimation {
          changeXYText()
        }
      }
    }
  }
  
  func changeXYText() {
    controlStatusText = String(
      format: """
             X %.2f
             Y %.2f
             """,
      x,
      y
    )
  }
}

extension ControlsView {
  @ViewBuilder func StyledArcKnob(
    _ text: String,
    value: Binding<Float>,
    range: ClosedRange<Float> = 0 ... 100,
    origin: Float = 0
  ) -> some View {
    ArcKnob(
      text,
      value: value,
      range: range,
      origin: origin
    )
    .backgroundColor(.gray.opacity(0.5))
    .foregroundColor(.white.opacity(0.5))
  }
  
  var layout: KeyboardLayout {
    let pitchRange = Pitch(intValue: lowestNote)...Pitch(intValue: hightestNote)
    
    return switch layoutType {
    case 0:
        .piano(pitchRange: pitchRange)
    case 1:
        .isomorphic(pitchRange: pitchRange)
    default:
        .guitar()
    }
  }
  
  func getParameter(index: Int) -> AUValue {
    conductor.instrument.parameters[index].value
  }
  
  func setParameter(_ value: AUValue, index: Int) {
    conductor.instrument.parameters[index].value = value
  }
}

#Preview {
  ControlsView()
}

/*
 Instrument SFZ 파라미터 목록
 
 0 Master Volume 0.0...1.0
 1 Pitch bend (semitones) -24.0...24.0
 2 Vibrato Depth 0.0...12.0
 3 Vibrato Speed (hz) 0.0...200.0
 4 Voice Vibrato (semitones) 0.0...24.0
 5 Voice Vibrato speed (Hz) 0.0...200.0
 6 Filter Cutoff 1.0...1000.0
 7 Filter Strength 1.0...1000.0
 8 Filter Resonance -20.0...20.0
 9 Glide rate (sec/octave)) 0.0...20.0
 10 Attack Duration (s) 0.0...10.0
 11 Hold Duration (s) 0.0...10.0
 12 Decay Duration (s) 0.0...10.0
 13 Sustain Level 0.0...1.0
 14 Release Duration (s) 0.0...10.0
 15 Filter Attack Duration (s) 0.0...10.0
 16 Filter Decay Duration (s) 0.0...10.0
 17 Filter Sustain Level 0.0...1.0
 18 Filter Release Duration (s) 0.0...10.0
 19 Pitch Attack Duration (s) 0.0...10.0
 20 Pitch Decay Duration (s) 0.0...10.0
 21 Pitch Sustain Level 0.0...1.0
 22 Pitch Release Duration (s) 0.0...10.0
 23 Pitch EG Amount duration (semitones) 0.0...12.0
 24 restartVoiceLFO 0.0...1.0
 25 Filter Enable 0.0...1.0
 26 loopThruRelease 0.0...1.0
 27 isMonophonic 0.0...1.0
 28 isLegato 0.0...1.0
 29 Key Tracking -2.0...2.0
 30 Filter Envelope Scaling 0.0...1.0
 */
