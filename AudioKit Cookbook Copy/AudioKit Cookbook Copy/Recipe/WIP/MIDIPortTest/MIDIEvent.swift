//
//  MIDIEvent.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import AudioKit
import CoreMIDI
import Foundation

extension MIDIStatusType: Codable {}

struct MIDIEvent: Codable, Identifiable {
  var id: String {
    "\(statusType)_\(channel)_\(data1)_\(data2 ?? 0)_\(portUniqueID?.description ?? "NoID")"
  }
  
  var statusType: MIDIStatusType
  var channel: MIDIChannel
  var data1: MIDIByte
  var data2: MIDIByte?
  var portUniqueID: MIDIUniqueID?
  
  var statusDescription: String {
    statusType.description
  }
  
  var channelDescription: String {
    "\(channel + 1)"
  }
  
  var data1Description: String {
    switch statusType {
    case .noteOn:
      String(data1)
    case .noteOff:
      String(data1)
    case .controllerChange:
      "\(data1.description): \(MIDIControl(rawValue: data1)!.description)"
    case .programChange:
      data1.description
    default:
      "-"
    }
  }
  
  var data2Description: String {
    guard let data2 else {
      return "-"
    }
    
    return switch statusType {
    case .noteOn, .noteOff, .controllerChange:
      data2.description
    default:
      "-"
    }
  }
}
