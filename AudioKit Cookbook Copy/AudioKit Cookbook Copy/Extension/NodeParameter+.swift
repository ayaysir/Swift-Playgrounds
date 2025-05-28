//
//  NodeParameter+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 5/5/25.
//

import AudioKit

extension NodeParameter: @retroactive Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(def.identifier)
  }
}

extension NodeParameter: @retroactive Equatable {
  public static func == (lhs: NodeParameter, rhs: NodeParameter) -> Bool {
    // NodeParameter wraps AUParameter which should
    // conform to equtable as they are NSObjects
    return lhs.parameter == rhs.parameter
  }
}
