//
//  MIDIPortTestView.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import AudioKitEX
import AudioKitUI
import CoreMIDI
import Foundation
import SwiftUI

struct MIDIPortTestView: View {
  @StateObject var conductor: MIDIPortTestConductor = .init()
  @State private var selectedPort1Uid: MIDIUniqueID?
  @State private var selectedPort2Uid: MIDIUniqueID?
  
  enum PortID {
    case port1, port2
  }
  
  var body: some View {
    VStack {
      HeaderArea
        .frame(height: 80)
      Divider()
      TabView {
        VStack {
          Port1SelectArea
          PortEventArea(portID: .port1)
          Spacer()
        }
        VStack {
          Port2SelectArea
          PortEventArea(portID: .port2)
          Spacer()
        }
      }
      .frame(height: 165)
      .tabViewStyle(.page)
      .onAppear {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
      }
      Divider()
      VStack {
        Toggle(isOn: $conductor.outputIsOpen) {
          Text("Use midi.openOutputs()")
        }
        Toggle(isOn: $conductor.inputPortIsSwapped) {
          Text("Swap UID for the virtual Input Port")
        }
        Toggle(isOn: $conductor.outputPortIsSwapped) {
          Text("Swap UID for the virtual Output Port")
        }
      }
      .bold()
      .padding(.horizontal, 10)
      LogResetButtonArea
      Divider()
      LogHeaderArea
        .frame(height: 10)
      ScrollView {
        LogDataArea
      }
    }
    .navigationTitle("MIDI Port Test")
    .padding(5)
    .onAppear(perform: conductor.start)
    .onDisappear(perform: conductor.stop)
  }
}

extension MIDIPortTestView {
  private var HeaderArea: some View {
    HStack {
      HeaderCell(
        "Input Ports [\(conductor.inputUIDs.count)]",
        conductor.inputNames[0],
        "(UID: \(conductor.inputUIDs[0]))"
      )
      Divider()
      HeaderCell(
        "Dest. Ports [\(conductor.destinationUIDs.count)]",
        conductor.destinationNames[0],
        "(UID: \(conductor.destinationUIDs[0]))"
      )
      Divider()
      HeaderCell(
        "Virtual Input Ports [\(conductor.virtualInputUIDs.count)]",
        conductor.virtualInputNames[0],
        "(UID: \(conductor.virtualInputUIDs[0]))"
      )
      Divider()
      HeaderCell(
        "Virtual Output Ports [\(conductor.virtualOutputUIDs.count)]",
        conductor.virtualOutputNames[0],
        "(UID: \(conductor.virtualOutputUIDs[0]))"
      )
    }
  }
  
  private var Port1SelectArea: some View {
    HStack {
      Text("Destination Ports:")
        .bold()
      Picker("Destination Ports:", selection: $selectedPort1Uid) {
        Text("All")
          .tag(nil as MIDIUniqueID?)
        ForEach(conductor.destinationNames.indices, id: \.self) { i in
          Text("\(conductor.destinationNames[i])")
            .tag(conductor.destinationUIDs[i] as MIDIUniqueID?)
        }
      }
    }
    .frame(height: 30, alignment: .leading)
  }
  
  private var Port2SelectArea: some View {
    HStack {
      Text("Virtual Output Ports:")
        .bold()
      Picker("Virtual Output Ports:", selection: $selectedPort2Uid) {
        Text("All")
          .tag(nil as MIDIUniqueID?)
        ForEach(conductor.virtualOutputUIDs.indices, id: \.self) { i in
          Text("\(conductor.virtualOutputNames[i])")
            .tag(conductor.virtualOutputUIDs[i] as MIDIUniqueID?)
        }
      }
    }
    .frame(height: 30, alignment: .leading)
  }
  
  private var LogResetButtonArea: some View {
    Button {
      conductor.resetLog()
    } label: {
      Text("Reset Logs")
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .tint(.gray)
  }
  
  private var LogHeaderArea: some View {
    HStack(spacing: 0) {
      MIDILogCell(category: .title, "Status")
      Divider()
      MIDILogCell(category: .title, "Channel")
      Divider()
      MIDILogCell(category: .title, "Data1")
      Divider()
      MIDILogCell(category: .title, "Data2")
      Divider()
      MIDILogCell(category: .title, "PortID")
      Divider()
      MIDILogCell(category: .title, "Device")
      Divider()
      MIDILogCell(category: .title, "Manufact.")
    }
  }
  
  private var PREVIEW_LogDataArea: some View {
    ForEach(0..<20) { _ in
      HStack(spacing: 0) {
        MIDILogCell(category: .row, "1")
        MIDILogCell(category: .row, "2")
        MIDILogCell(category: .row, "3")
        MIDILogCell(category: .row, "4")
        MIDILogCell(category: .row, "5")
        MIDILogCell(category: .row, "6")
        MIDILogCell(category: .row, "7")
      }
    }
  }
  
  private var LogDataArea: some View {
    ForEach(conductor.log.indices, id: \.self) { i in
      LazyHStack(spacing: 0) {
        let event = conductor.log[i]
        
        MIDILogCell(category: .row, "\(event.statusDescription)")
        MIDILogCell(category: .row, "\(event.channelDescription)")
        MIDILogCell(category: .row, "\(event.data1Description)")
        MIDILogCell(category: .row, "\(event.data2Description)")
        
        let portDescription = conductor.inputPortDescription(forUID: event.portUniqueID)
        MIDILogCell(category: .row, "\(portDescription.UID)")
        MIDILogCell(category: .row, "\(portDescription.device)")
        MIDILogCell(category: .row, "\(portDescription.manufacturer)")
        
        // 로딩 오래 걸리고 메인 스레드 멈춤 원인 => inputPortDescription이 원이
      }
      .foregroundColor(i == 0 ? .yellow : .primary)
    }
  }
  
 
  
  @ViewBuilder func PortEventArea(portID: PortID) -> some View {
    VStack {
      HStack {
        let noteArray = if portID == .port1 {
          [60, 62, 64, 67, 69]
        } else {
          [72, 74, 76, 78, 80]
        }
        
        ForEach(noteArray, id: \.self) { number in
          VStack {
            MIDIEventButton(
              buttonTitle: "NoteOn \(number)",
              eventToSend: .init(
                statusType: .noteOn,
                channel: 0,
                data1: MIDIByte(number),
                data2: 90
              ),
              to: portID == .port1 ? selectedPort1Uid : selectedPort2Uid
            )
            MIDIEventButton(
              buttonTitle: "NoteOff \(number)",
              tint: .gray,
              eventToSend: .init(
                statusType: .noteOff,
                channel: 0,
                data1: MIDIByte(number),
                data2: 90
              ),
              to: portID == .port1 ? selectedPort1Uid : selectedPort2Uid
            )
          }
        }
      }
      HStack {
        RandomProgramChangeButton(to: portID)
        
        MIDIEventButton(
          buttonTitle: "Send CC 1(Modul.) | 127",
          tint: .indigo,
          eventToSend: MIDIEvent(
            statusType: .controllerChange,
            channel: 0,
            data1: 1,
            data2: 127
          ),
          to: portID == .port1 ? selectedPort1Uid : selectedPort2Uid
        )
        
        MIDIEventButton(
          buttonTitle: "Send CC 1(Modul.) | 0",
          tint: .gray,
          eventToSend: MIDIEvent(
            statusType: .controllerChange,
            channel: 0,
            data1: 1,
            data2: 0
          ),
          to: portID == .port1 ? selectedPort1Uid : selectedPort2Uid
        )
      }
    }
  }
  
  @ViewBuilder func MIDIEventButton(
    buttonTitle: String,
    font: Font = .system(size: 8, weight: .semibold),
    tint: Color = .teal,
    eventToSend: MIDIEvent,
    to portID: MIDIUniqueID?
  ) -> some View {
    Button(buttonTitle) {
      if let portID {
        conductor.sendEvent(eventToSend: eventToSend, portIDs: [portID])
      } else {
        conductor.sendEvent(eventToSend: eventToSend, portIDs: nil)
      }
    }
    .font(font)
    .buttonStyle(.bordered)
    .tint(tint)
  }
  
  private func RandomProgramChangeButton(to portID: PortID) -> some View {
    Button("Change Random Inst.") {
      let eventToSend: MIDIEvent = .init(
        statusType: .programChange,
        channel: 0,
        data1: .random(in: 0...127)
      )
      
      let portIDArray: [MIDIUniqueID]? = {
        if portID == .port1, let selectedPort1Uid {
          [selectedPort1Uid]
        } else if portID == .port2, let selectedPort2Uid {
          [selectedPort2Uid]
        } else {
          nil
        }
      }()
      
      conductor.sendEvent(
        eventToSend: eventToSend,
        portIDs: portIDArray
      )
    }
    .font(.system(size: 8, weight: .semibold))
    .buttonStyle(.bordered)
    .tint(.pink)
  }
  
  @ViewBuilder func HeaderCell(_ title: String, _ values: String...) -> some View {
    VStack {
      Text(verbatim: title)
        .font(.system(size: 12, weight: .semibold))
      ForEach(values.indices, id: \.self) { i in
        Text(verbatim: values[i])
          .font(.system(size: 10, design: .monospaced))
      }
    }
    .multilineTextAlignment(.center)
  }
  
  enum MIDILogCellCategory {
    case title, row
  }
  
  private func MIDILogCell(
    category: MIDILogCellCategory,
    _ value: String
  ) -> some View {
    if category == .title {
      Text(value)
        .font(.system(size: 10, weight: .semibold))
        .frame(width: 55, height: 10)
    } else {
      Text(value)
        .font(.system(size: 9, design: .monospaced))
        .frame(width: 55, height: 10)
    }
  }
}

#Preview {
  MIDIPortTestView()
}
