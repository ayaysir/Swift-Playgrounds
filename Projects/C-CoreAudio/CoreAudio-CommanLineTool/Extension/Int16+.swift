//
//  Int16+.swift
//  CoreAudio-CommanLineTool
//
//  Created by 윤범태 on 2/27/25.
//

extension Int16 {
  var toBigEndian: Int16 {
    .init(bigEndian: self)
  }
}
