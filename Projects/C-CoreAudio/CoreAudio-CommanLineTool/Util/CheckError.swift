//
//  CheckError.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/3/25.
//

import Foundation

func checkError(_ message: String, callback: () -> (OSStatus)) {
  let status = callback()
  guard status == noErr else {
    print("Error: \(message), \(status.debugDescription)")
    exit(1)
  }
}
