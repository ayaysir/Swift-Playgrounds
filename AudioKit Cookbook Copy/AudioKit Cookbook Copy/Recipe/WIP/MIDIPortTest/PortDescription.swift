//
//  PortDescription.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/22/25.
//

import Foundation

struct PortDescription {
  var UID: String
  var manufacturer: String
  var device: String
  
  init(withUID: String, withManufacturer: String, withDevice: String) {
    UID = withUID
    manufacturer = withManufacturer
    device = withDevice
  }
}
