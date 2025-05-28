//
//  CGFloat+OSSafeVector.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/5/25.
//

import Foundation

extension CGFloat {
#if os(macOS)
  var osSafeVector: Float {
    Float(self)
  }
#endif
}

extension Float {
  var osSafeVector: Float {
    self
  }
}
