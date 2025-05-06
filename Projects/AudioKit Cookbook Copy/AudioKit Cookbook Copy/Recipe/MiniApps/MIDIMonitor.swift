//
//  MIDIMonitor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/6/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

// MARK: - Structs

struct MIDIMonitorData {
  var noteOn = 0
  var velocity = 0
  var noteOff = 0
  var channel = 0
  var afterTouch = 0
  var afterTouchNoteNumber = 0
  var programChange = 0
  var pitchWheelValue = 0
  var controllerNumber = 0
  var controllerValue = 0
}

enum MIDIEventType {
  case none
  case noteOn
  case noteOff
  case continuousControl
  case programChange
}

// MARK: - Conductor

class MIDIMonitorConductor: ObservableObject {
#if os(iOS)
  let midi = MIDI.sharedInstance
#else
  let midi = MIDI()
#endif
  
  @Published var data = MIDIMonitorData()
  @Published var isShowingMIDIReceived: Bool = false
  @Published var isToggleOn: Bool = false
  @Published var oldControllerValue: Int = 0
  @Published var midiEventType: MIDIEventType = .none
  
  init() {}
  
  func start() {
    midi.openInput(name: "Bluetooth")
    midi.openInput()
    midi.addListener(self)
  }
  
  func stop() {
    midi.closeAllInputs()
  }
}

// MARK: MIDI Listener delegates

extension MIDIMonitorConductor: MIDIListener {
  func receivedMIDINoteOn(
    noteNumber: AudioKit.MIDINoteNumber,
    velocity: AudioKit.MIDIVelocity,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      
      midiEventType = .noteOn
      isShowingMIDIReceived = true
      data.noteOn = Int(noteNumber)
      data.velocity = Int(velocity)
      data.channel = Int(channel)
      
      if data.velocity == 0 {
        withAnimation(.easeOut(duration: 0.4)) {
          self.isShowingMIDIReceived = false
        }
      }
    }
  }
  
  func receivedMIDINoteOff(
    noteNumber: AudioKit.MIDINoteNumber,
    velocity: AudioKit.MIDIVelocity,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      
      midiEventType = .noteOff
      isShowingMIDIReceived = false
      data.noteOff = Int(noteNumber)
      data.velocity = Int(velocity)
      data.channel = Int(channel)
    }
  }
  
  func receivedMIDIController(
    _ controller: AudioKit.MIDIByte,
    value: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      
      midiEventType = .continuousControl
      isShowingMIDIReceived = true
      data.controllerNumber = Int(controller)
      data.controllerValue = Int(value)
      oldControllerValue = Int(value)
      data.channel = Int(channel)
      
      if oldControllerValue == Int(value) {
        // Fade out the MIDI received indicator.
        DispatchQueue.main.async {
          withAnimation(.easeOut(duration: 0.4)) {
            self.isShowingMIDIReceived = false
          }
        }
      }
      
      // Show the solid color indicator when the CC value is toggled from 0 to 127
      // Otherwise toggle it off when the CC value is toggled from 127 to 0
      // Useful for stomp box and on/off UI toggled states
      if value == 127 {
        DispatchQueue.main.async {
          self.isToggleOn = true
        }
      } else {
        // Fade out the Toggle On indicator.
        DispatchQueue.main.async {
          self.isToggleOn = false
        }
      }
    }
  }
  
  func receivedMIDIAftertouch(
    noteNumber: AudioKit.MIDINoteNumber,
    pressure: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      data.afterTouchNoteNumber = Int(noteNumber)
      data.afterTouch = Int(pressure)
      data.channel = Int(channel)
    }
  }
  
  func receivedMIDIAftertouch(
    _ pressure: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      data.afterTouch = Int(pressure)
      data.channel = Int(channel)
    }
  }
  
  func receivedMIDIPitchWheel(
    _ pitchWheelValue: AudioKit.MIDIWord,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      data.pitchWheelValue = Int(pitchWheelValue)
      data.channel = Int(channel)
    }
  }
  
  func receivedMIDIProgramChange(
    _ program: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      midiEventType = .programChange
      isShowingMIDIReceived = true
      data.programChange = Int(program)
      data.channel = Int(channel)
      // Fade out the MIDI received indicator, since program changes don't have a MIDI release/note off.
      DispatchQueue.main.async {
        withAnimation(.easeOut(duration: 0.4)) {
          self.isShowingMIDIReceived = false
        }
      }
    }
  }
  
  func receivedMIDISystemCommand(
    _ data: [AudioKit.MIDIByte],
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {}
  
  func receivedMIDISetupChange() {}
  
  func receivedMIDIPropertyChange(
    propertyChangeInfo: MIDIObjectPropertyChangeNotification
  ) {}
  
  func receivedMIDINotification(
    notification: MIDINotification
  ) {}
}

// MARK: - View

struct MIDIMonitorView: View {
  @StateObject private var conductor = MIDIMonitorConductor()
  private let mainTintColor: Color = .teal
  
  var body: some View {
    VStack {
      midiReceivedIndicator
      
      List {
        Section("Note On") {
          HStack {
            Text("Note Number")
            Spacer()
            Text("\(conductor.data.noteOn)")
          }
          .foregroundColor(conductor.midiEventType == .noteOn ? mainTintColor : .primary)
        }
        
        Section("Note Off") {
          HStack {
            Text("Note Number")
            Spacer()
            Text("\(conductor.data.noteOff)")
          }
        }
        .foregroundColor(conductor.midiEventType == .noteOff ? mainTintColor : .primary)
        
        Section("Continuous Controller") {
          HStack {
            Text("Controller Number")
            Spacer()
            Text("\(conductor.data.controllerNumber)")
          }
          HStack {
            Text("Continuous Value")
            Spacer()
            Text("\(conductor.data.controllerValue)")
          }
        }
        .foregroundColor(conductor.midiEventType == .continuousControl ? mainTintColor : .primary)
        
        Section("Program Change") {
          HStack {
            Text("Program Number")
            Spacer()
            Text("\(conductor.data.programChange)")
          }
        }
        .foregroundColor(conductor.midiEventType == .programChange ? mainTintColor : .primary)
        
        Section {
          HStack {
            Text("Selected MIDI Channel")
            Spacer()
            Text("\(conductor.data.channel)")
          }
        }
      }
    }
    .navigationTitle("MIDI Monitor")
#if os(macOS)
    .frame(height: 450)
#endif
    .onAppear {
      conductor.start()
    }
    .onDisappear {
      conductor.stop()
    }
  }
  
  private var midiReceivedIndicator: some View {
    HStack(spacing: 15) {
      Text("MIDI In")
        .fontWeight(.medium)
      Circle()
        .strokeBorder(mainTintColor.opacity(0.5), lineWidth: 1)
        .background(Circle().fill(conductor.isShowingMIDIReceived ? mainTintColor : mainTintColor.opacity(0.2)))
      
      Spacer()
      
      Text("Toggle On")
        .fontWeight(.medium)
      Circle()
        .strokeBorder(.red.opacity(0.5), lineWidth: 1)
        .background(Circle().fill(conductor.isToggleOn ? .red : .red.opacity(0.2)))
        .frame(maxWidth: 20, maxHeight: 20)
        .shadow(color: conductor.isToggleOn ? .red : .clear, radius: 5)
    }
    .padding([.top, .horizontal], 20)
    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
  }
}

#Preview {
  MIDIMonitorView()
}
