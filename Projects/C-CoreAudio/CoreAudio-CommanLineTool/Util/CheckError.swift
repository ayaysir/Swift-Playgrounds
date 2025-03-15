//
//  CheckError.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 3/3/25.
//

import Foundation
import OpenAL

func checkError(_ message: String, callback: () -> (OSStatus)) {
  let status = callback()
  guard status == noErr else {
    print("Error: \(message), \(status.debugDescription)")
    exit(1)
  }
}

func checkAL(_ message: String) {
  let alError = alGetError()
  guard alError == AL_NO_ERROR else {
    let alErrorMessage: String = switch alError {
    case AL_INVALID_NAME:
      "AL_INVALID_NAME"
    case AL_INVALID_ENUM:
      "AL_INVALID_ENUM"
    case AL_INVALID_VALUE:
      "AL_INVALID_VALUE"
    case AL_OUT_OF_MEMORY:
      "AL_OUT_OF_MEMORY"
    case AL_INVALID_OPERATION:
      "AL_INVALID_OPERATION"
    default:
      "Unknown AL error '\(alError)'"
    }
    print("Error: \(message), \(alErrorMessage)")
    exit(1)
  }
}
