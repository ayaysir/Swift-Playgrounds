//
//  OsStatus+.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/26/25.
//

import Foundation

extension OSStatus {
  var errorBytes: [CChar] {
    // [
    //   CChar((self >> 24) & 0xFF),
    //   CChar((self >> 16) & 0xFF),
    //   CChar((self >> 8) & 0xFF),
    //   CChar(self & 0xFF),
    // ]
    // (0...3).map { CChar((self >> (24 - ($0 * 8))) & 0xFF) }
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

