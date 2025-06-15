//
//  String+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/15/25.
//

extension String {
  var spacedCamelCase: String {
    return self.replacingOccurrences(
      of: "([a-z])([A-Z])",
      with: "$1 $2",
      options: .regularExpression
    )
  }
}
