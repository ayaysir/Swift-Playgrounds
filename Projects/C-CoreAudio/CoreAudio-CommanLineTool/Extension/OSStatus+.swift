//
//  OsStatus+.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/26/25.
//

import Foundation

extension OSStatus {
  var debugDescription: String {
    let fourCC = String(format: "%c%c%c%c",
                        (self >> 24) & 0xFF,
                        (self >> 16) & 0xFF,
                        (self >> 8) & 0xFF,
                        self & 0xFF
    )
    
    return "\(self) (\(fourCC))"
  }
}

