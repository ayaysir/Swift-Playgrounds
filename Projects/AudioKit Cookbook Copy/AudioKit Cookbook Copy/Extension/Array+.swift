//
//  Array+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/3/25.
//

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
