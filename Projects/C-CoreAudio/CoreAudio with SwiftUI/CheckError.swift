//
//  CheckError.swift
//  CoreAudio with SwiftUI
//
//  Created by 윤범태 on 3/17/25.
//

import Foundation

func check(_ status: OSStatus) -> Bool {
  guard status == noErr else {
    print("OSStatus Error: \(status.debugDescription)")
    return false
  }
  
  return true
}

extension OSStatus {
  var errorBytes: [CChar] {
    (0...3).map {
      CChar(truncatingIfNeeded: (self >> (24 - ($0 * 8))) & 0xFF)
    }
  }
  
  var debugDescription: String {
    return if errorBytes.allSatisfy({ isprint(Int32($0)) != 0}) {
      "\(self) (\(String(cString: errorBytes + [0])))"
    } else {
      "\(self)"
    }
  }
}

