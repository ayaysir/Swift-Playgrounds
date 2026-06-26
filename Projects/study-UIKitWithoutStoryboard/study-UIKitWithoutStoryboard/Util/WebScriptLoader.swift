//
//  WebScriptLoader.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 6/27/26.
//

import Foundation

func injectedScript(
  _ fileName: String,
  fileExtension: String = "js"
) -> String {
  guard let url = Bundle.main.url(
    forResource: fileName,
    withExtension: fileExtension
  ) else {
    fatalError("\(fileName).\(fileExtension) not found")
  }

  do {
    return try String(contentsOf: url)
  } catch {
    fatalError(error.localizedDescription)
  }
}
