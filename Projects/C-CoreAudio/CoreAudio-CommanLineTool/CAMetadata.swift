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
  // AudioFileGetPropertyInfo는 속성 정보만 확인합니다. 실제 속성의 값을 읽지는 않습니다. (값의 크기만 확인)
  theErr = AudioFileGetPropertyInfo(
    audioFile,
    kAudioFilePropertyInfoDictionary, // propertyID: 확인하려는 속성의 식별자
    &dictionarySize, // propertySize: 해당 속성의 크기를 반환할 변수.
    nil // isWritable: 이 속성이 쓰기 가능한지 여부를 반환할 변수. 
  )
  
  guard theErr == noErr else {
    print("2: Error opening audio file: \(theErr)")
    return
  }
  
  var dictionary: CFDictionary?
  
  // Swift에서 Core Foundation 타입(CFDictionary)을 다룰 때는 UnsafeMutablePointer<CFDictionary?>을 명시적으로 사용해야 합니다.
  // withUnsafeMutablePointer(to:)를 사용하여 안전하게 포인터를 전달합니다.
  withUnsafeMutablePointer(to: &dictionary) { dictionaryPointer in
    // AudioFileGetProperty 함수는 지정된 오디오 파일에서 특정 속성의 실제 값을 가져오는 데 사용됩니다.
    // 실제 속성 값을 읽습니다. AudioFileGetPropertyInfo로 얻은 정보를 바탕으로 속성의 값을 읽을 수 있습니다.
    theErr = AudioFileGetProperty(
      audioFile,
      kAudioFilePropertyInfoDictionary,
      &dictionarySize,
      dictionaryPointer // 속성 값을 저장할 버퍼.
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
