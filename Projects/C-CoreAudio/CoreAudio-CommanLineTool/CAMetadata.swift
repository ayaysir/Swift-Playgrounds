//
//  CAMetadata.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/26/25.
//

import AudioToolbox

func CAMetadata() {
  print("Enter audio file url:", terminator: " ")
  guard let audioFilePath = readLine() else {
      print("Please provide the path to an audio file.")
    return
  }
  
  print(audioFilePath)
  
  let audioURL = URL(filePath: audioFilePath)
  var audioFile: AudioFileID?
  var theErr: OSStatus = noErr
  
  // 대부분의 코어 오디오 함수는 OSStatus 타입의 반환값을 통해 성공/실패를 전달
  // noErr(0) 외의 다른 값은 오류를 나타낸다
  theErr = AudioFileOpenURL(
    audioURL as CFURL,
    .readPermission,
    0,  // inFileTypeHint
    &audioFile
  )
  
  guard let audioFile, theErr == noErr else {
    print("1: Error opening audio file: \(theErr)")
    return
  }
  
  var dictionarySize: UInt32 = 0
  theErr = AudioFileGetPropertyInfo(
    audioFile,
    kAudioFilePropertyInfoDictionary,
    &dictionarySize,
    nil // isWritable
  )
  
  guard theErr == noErr else {
    print("2: Error opening audio file: \(theErr)")
    return
  }
  
  var dictionary: CFDictionary?
  
  // Swift에서 Core Foundation 타입(CFDictionary)을 다룰 때는 UnsafeMutablePointer<CFDictionary?>을 명시적으로 사용해야 합니다.
  // withUnsafeMutablePointer(to:)를 사용하여 안전하게 포인터를 전달합니다.
  withUnsafeMutablePointer(to: &dictionary) { dictionaryPointer in
    theErr = AudioFileGetProperty(
      audioFile,
      kAudioFilePropertyInfoDictionary,
      &dictionarySize,
      dictionaryPointer
    )
  }
  
  guard theErr == noErr else {
    print("3: Error opening audio file: \(theErr)")
    return
  }
  
  print("dictionary: \(String(describing: dictionary))")
  theErr = AudioFileClose(audioFile)
  
  guard theErr == noErr else {
    print("4: Error opening audio file: \(theErr)")
    return
  }
}
