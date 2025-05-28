//
//  PrintAllBundleFiles.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/1/25.
//

import Foundation

func printAllBundleFiles() {
  guard let resourceURL = Bundle.main.resourceURL else {
    print("⚠️ Bundle resourceURL 없음")
    return
  }
  
  if let enumerator = FileManager.default.enumerator(at: resourceURL, includingPropertiesForKeys: nil) {
    for case let fileURL as URL in enumerator {
      print(fileURL.path)
    }
  } else {
    print("⚠️ 파일 열거 실패")
  }
}
