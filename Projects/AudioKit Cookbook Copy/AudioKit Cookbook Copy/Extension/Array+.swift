//
//  Array+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/3/25.
//

import Foundation
import SporthAudioKit

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
  
  /// 컬렉션을 지정된 크기만큼 나누어 2차원 배열로 반환합니다.
  ///
  /// 이 함수는 큰 컬렉션을 일정한 크기의 덩어리로 나누어 처리할 때 유용합니다.
  /// 마지막 덩어리는 남은 요소 수에 따라 지정한 크기보다 작을 수 있습니다.
  ///
  /// - Parameter size: 각 덩어리의 최대 요소 수.
  /// - Returns: 최대 `size` 개의 요소를 가진 배열들의 배열을 반환합니다.
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}

extension Array where Element == SporthAudioKit.Operation {
  func n(_ oneBasedIndex: Int) -> Element {
    self[oneBasedIndex - 1]
  }
}
