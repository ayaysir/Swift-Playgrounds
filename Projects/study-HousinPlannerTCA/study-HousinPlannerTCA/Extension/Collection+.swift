//
//  Collection+.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/8/25.
//

import Foundation

extension Collection {
  /// Safely retrieves an element from the collection at the given index.
  /// Returns `nil` if the index is out of bounds, otherwise returns the element.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
  
  subscript(safe index: Index, default defaultValue: Element) -> Element {
    (indices.contains(index) ? self[index] : defaultValue)
  }
}
