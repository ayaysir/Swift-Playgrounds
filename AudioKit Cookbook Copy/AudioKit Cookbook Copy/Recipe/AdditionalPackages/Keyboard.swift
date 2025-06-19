//
//  Keyboard.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import Keyboard
import SwiftUI
import Tonic
import AudioKit
import AudioKitUI

private extension InstrumentSFZConductor {
  func noteOnWithVerticalVelocity(pitch: Pitch, point: CGPoint) {
    let midiVelocity = Int(point.y * 127)
    instrument.play(
      noteNumber: MIDINoteNumber(pitch.midiNoteNumber),
      velocity: MIDIVelocity(midiVelocity),
      channel: 0
    )
  }
}

struct KeyboardView: View {
  @Environment(\.colorScheme) var colorScheme
  @StateObject private var conductor = InstrumentSFZConductor()
  @State var lowNote = 80
  @State var highNote = 104
  @State var scaleIndex = Scale.allCases.firstIndex(of: .chromatic) ?? 0 {
    didSet { scaleIndexDidSet() }
  }
  @State var scale: Scale = .chromatic
  @State var root: NoteClass = .C
  @State var rootIndex = 0
  
  @State private var VNodeOutputView: NodeOutputView?
  
  let randomColors: [Color] = {
    (0 ... 12).map { _ in
      Color(red: Double.random(in: 0.3 ... 1),
            green: Double.random(in: 0.3 ... 1),
            blue: Double.random(in: 0.3 ... 1), opacity: 1)
    }
  }()
  
  var body: some View {
    TabView {
      HStack(spacing: 50) {
        Keyboard(
          layout: .verticalIsomorphic(pitchRange: Pitch(48)...Pitch(77)),
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff
        )
        
        Keyboard(
          layout: .verticalPiano(
            pitchRange: Pitch(48)...Pitch(77),
            initialSpacerRatio: KeyboardSpacingInfo.evenSpacingInitialSpacerRatio,
            spacerRatio: KeyboardSpacingInfo.evenSpacingSpacerRatio,
            relativeBlackKeyWidth: KeyboardSpacingInfo.evenSpacingRelativeBlackKeyWidth
          ),
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff
        )
      }
      .background(keyboardBackgroundColor)
      .tabItem {
        Label("세로 피아노", systemImage: "blinds.vertical.closed")
      }
      
      VStack {
        if let VNodeOutputView {
          VNodeOutputView
        }
        
        Stepper("Lowest Note \(Pitch(intValue: lowNote).note(in: .C).description)") {
          if lowNote < 126 && highNote > lowNote + 12 {
            lowNote += 1
          }
        } onDecrement: {
          if lowNote > 0 {
            lowNote -= 1
          }
        }
        .monospaced()
        
        Stepper("Highest Note: \(Pitch(intValue: highNote).note(in: .C).description)") {
          if highNote < 126 {
            highNote += 1
          }
        } onDecrement: {
          if highNote > 1 && highNote > lowNote + 12 {
            highNote -= 1
          }
        }
        .monospaced()
        
        Keyboard(
          layout: .piano(
            pitchRange: Pitch(intValue: lowNote)...Pitch(intValue: highNote)
          ),
          noteOn: conductor.noteOnWithVerticalVelocity,
          noteOff: conductor.noteOff
        )
        .background(keyboardBackgroundColor)
      }
      .padding()
      .tabItem {
        Label("범위 조절", systemImage: "slider.horizontal.3")
      }
      
      VStack {
        if let VNodeOutputView {
          VNodeOutputView
        }
        
        Stepper( "Root: \(root.description)") {
          changeRoot(isIncrement: true)
        } onDecrement: {
          changeRoot(isIncrement: false)
        }
        .font(.system(size: 12))
        .monospaced()
        
        Stepper("Scale: \(scale.description)") {
          scaleIndex += 1
        } onDecrement: {
          scaleIndex -= 1
        }
        .font(.system(size: 12))
        .lineLimit(1)
        .monospaced()
        
        let pitchStart = Pitch(intValue: 60 + rootIndex)
        let pitchEnd = Pitch(intValue: 84 + rootIndex)
        let pitchRange = pitchStart...pitchEnd
        Keyboard(
          layout: .isomorphic(
            pitchRange: pitchRange,
            root: root,
            scale: scale
          ),
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff
        )
        .background(keyboardBackgroundColor)
      }
      .padding()
      .tabItem {
        Label("스케일", systemImage: "music.quarternote.3")
      }
      
      VStack {
        Keyboard(
          layout: .guitar(),
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff
        )
        { pitch, isActivated in
          let pressedColor = Color(PitchColor.newtonian[Int(pitch.pitchClass)])
          KeyboardKey(
            pitch: pitch,
            isActivated: isActivated,
            text: pitch.note(in: .F).description,
            pressedColor: pressedColor,
            alignment: .center
          )
        }
        .background(keyboardBackgroundColor)
        
        Keyboard(
          layout: .isomorphic(pitchRange: Pitch(48)...Pitch(65)),
          noteOn: conductor.noteOnWithVerticalVelocity(pitch:point:),
          noteOff: conductor.noteOff
        ) { pitch, isActivated in
          let pressedColor = Color(PitchColor.newtonian[Int(pitch.pitchClass)])
          KeyboardKey(
            pitch: pitch,
            isActivated: isActivated,
            text: pitch.note(in: .F).description,
            pressedColor: pressedColor
          )
        }
        .background(keyboardBackgroundColor)
        
        Keyboard(
          latching: true, // Latched keys stay on until they are pressed again (다시 누르기 전까지 누른 상태를 유지함; latch: 걸쇠를 걸다, 자물쇠를 잠그다)
          noteOn: conductor.noteOn,
          noteOff: conductor.noteOff
        ) { pitch, isActivated in
          if isActivated {
            Rectangle()
              .border(.gray, width: 0.5)
              .foregroundStyle(.black)
              .overlay {
                VStack {
                  Spacer()
                  Text(pitch.note(in: .C).description)
                    .font(.title)
                    .foregroundStyle(.white)
                }
              }
          } else {
            Rectangle()
              .border(.gray, width: 0.5)
              .foregroundStyle(randomColors[pitch.intValue % 12])
              
          }
        }
      }
      .padding()
      .tabItem {
        Label("기타", systemImage: "guitars")
      }
    }
    .tabViewStyle(.tabBarOnly)
    .navigationTitle("Keyboard Demo")
    .onAppear {
      VNodeOutputView = NodeOutputView(conductor.instrument)
      conductor.start()
    }
    .onDisappear(perform: conductor.stop)
  }
}

extension KeyboardView {
  var keyboardBackgroundColor: Color {
    colorScheme == .dark ?
                Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9)
  }
  
  func scaleIndexDidSet() {
    if scaleIndex >= Scale.allCases.count {
      scaleIndex = 0
    }
    if scaleIndex < 0 {
      scaleIndex = Scale.allCases.count - 1
    }
    scale = Scale.allCases[scaleIndex]
  }
  
  func changeRoot(isIncrement: Bool) {
    let allSharpNotes = (0...11).map {
      Note(pitch: Pitch(intValue: $0)).noteClass
    }
    var index = allSharpNotes.firstIndex(of: root.canonicalNote.noteClass) ?? 0
    index = (index + (isIncrement ? 1 :  -1))
      .clamped(to: 0...11)
    rootIndex = index
    root = allSharpNotes[index]
  }
}

struct KeyboardSpacingInfo {
  /// 각 흰 건반(Letter) 앞에 얼마나 여백을 둘지를 비율로 나타냄
  /// - 주로 검은 건반과의 상대적인 위치 보정에 사용됨
  /// - 예: D는 앞에 2/12 만큼 띄워짐 → C# 위치 확보용
  static let evenSpacingInitialSpacerRatio: [Letter: CGFloat] = [
    .C: 0.0,
    .D: 2.0 / 12.0,
    .E: 4.0 / 12.0,
    .F: 0.0 / 12.0,
    .G: 1.0 / 12.0,
    .A: 3.0 / 12.0,
    .B: 5.0 / 12.0
  ]
  
  /// 각 흰 건반의 자기 자신 이후에 생길 “스페이서” 길이 비율
  /// - 기본적으로 일정한 간격(7/12) 유지
  /// - 실제로는 전체 키 간격 = 앞쪽 initialSpacer + 자기 폭 + 뒤쪽 spacer
  static let evenSpacingSpacerRatio: [Letter: CGFloat] = [
    .C: 7.0 / 12.0,
    .D: 7.0 / 12.0,
    .E: 7.0 / 12.0,
    .F: 7.0 / 12.0,
    .G: 7.0 / 12.0,
    .A: 7.0 / 12.0,
    .B: 7.0 / 12.0
  ]
  
  /// 검은 건반의 상대 너비 비율
  /// - 1.0은 흰 건반과 동일한 폭, 0.58 정도가 일반적 현실 비율
  /// - 여기선 꽤 넓은 검은 건반으로 설정됨
  static let evenSpacingRelativeBlackKeyWidth: CGFloat = 7.0 / 12.0
}

#Preview {
  KeyboardView()
}
