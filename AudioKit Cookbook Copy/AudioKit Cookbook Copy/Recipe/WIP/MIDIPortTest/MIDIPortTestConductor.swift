//
//  MIDIPortTestConductor.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import CoreMIDI
import Foundation

@dynamicMemberLookup
class MIDIPortTestConductor: ObservableObject {
  private let LOG_SIZE = 30
  
  let inputUIDDevelop: Int32 = 1_200_000
  let outputUIDDevelop: Int32 = 1_500_000
  let inputUIDMain: Int32 = 2_200_000
  let outputUIDMain: Int32 = 2_500_000
  
  let midi = MIDI()
  
  @Published var log = [MIDIEvent]()
  private var logBuffer = [MIDIEvent]()
  private var logTimer: Timer?
  private var portDescriptionCache: [MIDIUniqueID : PortDescription] = [:]
  
  @Published var outputIsOpen: Bool = false {
    didSet { didSetOutputIsOpen() }
  }
  @Published var outputPortIsSwapped: Bool = false
  @Published var inputPortIsSwapped: Bool = false

  subscript<T>(dynamicMember keyPath: KeyPath<MIDI, T>) -> T {
    midi[keyPath: keyPath]
  }
  
  var inputInfos: [EndpointInfo] {
    midi.inputInfos
  }
  
  init() {
    midi.destroyAllVirtualPorts()
    midi.createVirtualInputPorts(count: 1, uniqueIDs: [inputUIDDevelop])
    midi.createVirtualOutputPorts(count: 1, uniqueIDs: [outputUIDDevelop])
    midi.addListener(self)
    
    logTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let self else { return }
      if logBuffer.isNotEmpty {
        DispatchQueue.main.async {
          // print("Log Buffer Flushed")
          self.flushLogBuffer()
        }
      }
    }
    
    print("Input Ports:")
    print(midi.inputInfos.map(\.displayName))
    print("Destination Ports:")
    print(midi.destinationInfos.map(\.displayName))
    
    // 미디 장비 정보 미리 캐싱: 메인 스레드에서 너무 오래 걸림
    DispatchQueue.global(qos: .background).async { [unowned self] in
      for info in inputInfos {
        portDescriptionCache[info.midiUniqueID] = .init(
          withUID: "\(info.midiUniqueID)",
          withManufacturer: info.manufacturer,
          withDevice: info.displayName
        )
      }
    }
  }
  
  func didSetOutputIsOpen() {
    print("outputIsOpen: \(outputIsOpen)")
    
    if outputIsOpen {
      openOutputs()
    } else {
      midi.closeOutput()
    }
  }
  
  func start() {
    midi.openInput()
  }
  
  func stop() {
    midi.closeAllInputs()
  }
  
  func openOutputs() {
    for uid in midi.destinationUIDs {
      midi.openOutput(uid: uid)
    }
    
    for uid in midi.virtualOutputUIDs {
      midi.openOutput(uid: uid)
    }
  }
  
  func inputPortDescription(forUID: MIDIUniqueID?) -> PortDescription {
    // print("inputPortDescription: \(String(describing: forUID))")
    guard let UID = swapVirtualInputPort(withUID: forUID) else {
      return .init(withUID: "-", withManufacturer: "-", withDevice: "-")
    }
    
    // 캐시 있으면 즉시 리턴
    if let cache = portDescriptionCache[UID] {
      return cache
    }
    
    var UIDString = forUID?.description ?? "-"
    var manufacturerString = "-"
    var deviceString = "-"
    
    for info in inputInfos where info.midiUniqueID == UID {
      UIDString = "\(info.midiUniqueID)"
      manufacturerString = info.manufacturer
      deviceString = info.displayName
      
      portDescriptionCache[UID] = .init(
        withUID: UIDString,
        withManufacturer: manufacturerString,
        withDevice: deviceString
      )
      
      break
    }
    
    return PortDescription(
      withUID: UIDString,
      withManufacturer: manufacturerString,
      withDevice: deviceString
    )
  }
  
  func appendToLog(eventToAdd: MIDIEvent) {
    logBuffer.append(eventToAdd)
  }
  
  private func flushLogBuffer() {
    guard !logBuffer.isEmpty else { return }
    log.insert(contentsOf: logBuffer.reversed(), at: 0)
    log = Array(log.prefix(LOG_SIZE))
    logBuffer.removeAll()
  }
  
  func resetLog() {
    log.removeAll()
  }

}

extension MIDIPortTestConductor {
  func swapVirtualOutputPorts(withUID uid: [MIDIUniqueID]?) -> [MIDIUniqueID]? {
    guard let uid, outputPortIsSwapped else {
      return uid
    }
    
    return switch uid {
    case [outputUIDMain]:
      [inputUIDMain]
    case [outputUIDDevelop]:
      [inputUIDDevelop]
    default:
      uid
    }
  }
  
  func swapVirtualInputPort(withUID uid: MIDIUniqueID?) -> MIDIUniqueID? {
    guard let uid, inputPortIsSwapped else {
      return uid
    }
    
    return switch uid {
    case outputUIDMain:
      inputUIDMain
    case outputUIDDevelop:
      inputUIDDevelop
    default:
      uid
    }
  }
  
  func sendEvent(
    eventToSend event: MIDIEvent,
    portIDs: [MIDIUniqueID]?
  ) {
    print(#function)
    
    let portIDs2: [MIDIUniqueID]? = swapVirtualOutputPorts(withUID: portIDs)
    // if let portIDs2 {
    //   // print("sendEvent: port: \(portIDs2[0].description)")
    // }
    
    switch event.statusType {
    case .controllerChange:
      midi.sendControllerMessage(
        event.data1,
        value: event.data2 ?? 0,
        channel: event.channel,
        endpointsUIDs: portIDs2
      )
    case .programChange:
      midi.sendEvent(
        AudioKit.MIDIEvent(
          programChange: event.data1,
          channel: event.channel
        )
      )
    case .noteOn:
      midi.sendNoteOnMessage(
        noteNumber: event.data1,
        velocity: event.data2 ?? 0,
        channel: event.channel,
        endpointsUIDs: portIDs2
      )
    case .noteOff:
      midi.sendNoteOffMessage(
        noteNumber: event.data1,
        channel: event.channel,
        endpointsUIDs: portIDs2
      )
    default:
      break
    }
  }
}

extension MIDIPortTestConductor:MIDIListener {
  func receivedMIDINoteOn(
    noteNumber: AudioKit.MIDINoteNumber,
    velocity: AudioKit.MIDIVelocity,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    Task { @MainActor in
      appendToLog(
        eventToAdd: MIDIEvent(
          statusType: .noteOn,
          channel: channel,
          data1: noteNumber,
          data2: velocity,
          portUniqueID: portID
        )
      )
    }
  }
  
  func receivedMIDINoteOff(
    noteNumber: AudioKit.MIDINoteNumber,
    velocity: AudioKit.MIDIVelocity,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    Task { @MainActor in
      appendToLog(
        eventToAdd: MIDIEvent(
          statusType: .noteOff,
          channel: channel,
          data1: noteNumber,
          data2: velocity,
          portUniqueID: portID
        )
      )
    }
  }
  
  func receivedMIDIController(
    _ controller: AudioKit.MIDIByte,
    value: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    Task { @MainActor in
      appendToLog(
        eventToAdd: MIDIEvent(
          statusType: .controllerChange,
          channel: channel,
          data1: controller,
          data2: value,
          portUniqueID: portID
        )
      )
    }
  }
  
  func receivedMIDIAftertouch(
    noteNumber: AudioKit.MIDINoteNumber,
    pressure: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    Task { @MainActor in
      appendToLog(
        eventToAdd: MIDIEvent(
          statusType: .channelAftertouch,
          channel: channel,
          data1: noteNumber,
          data2: pressure,
          portUniqueID: portID
        )
      )
    }
  }
  
  func receivedMIDIAftertouch(_ pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {  }
  
  func receivedMIDIPitchWheel(_ pitchWheelValue: AudioKit.MIDIWord, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {  }
  
  func receivedMIDIProgramChange(
    _ program: AudioKit.MIDIByte,
    channel: AudioKit.MIDIChannel,
    portID: MIDIUniqueID?,
    timeStamp: MIDITimeStamp?
  ) {
    Task { @MainActor in
      appendToLog(
        eventToAdd: MIDIEvent(
          statusType: .programChange,
          channel: channel,
          data1: program,
          portUniqueID: portID
        )
      )
    }
  }
  
  func receivedMIDISystemCommand(_ data: [AudioKit.MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {  }
  
  func receivedMIDISetupChange() {  }
  
  func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {  }
  
  func receivedMIDINotification(notification: MIDINotification) {  }
}
