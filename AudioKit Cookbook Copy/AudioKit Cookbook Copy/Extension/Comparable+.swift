//
//  Comparable+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import Foundation

extension Comparable {
  // ie: 5.clamped(to: 7...10)
  // ie: 5.0.clamped(to: 7.0...10.0)
  // ie: "a".clamped(to: "b"..."h")
  /// **OTCore:**
  /// Returns the value clamped to the passed range.
  dynamic func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}
