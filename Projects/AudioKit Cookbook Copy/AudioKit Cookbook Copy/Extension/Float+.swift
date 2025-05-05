//
//  Float+.swift
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
#else
  var osSafeVector: CGFloat {
    self
  }
#endif
}
