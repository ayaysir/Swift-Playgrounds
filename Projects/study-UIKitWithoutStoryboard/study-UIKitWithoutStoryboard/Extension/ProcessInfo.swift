//
//  ProcessInfo.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 3/19/26.
//

import Foundation

extension ProcessInfo {
  static var isPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
}
