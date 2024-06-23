//
//  FileManager+.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/23/24.
//

import Foundation

extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.bgsmm.study.widget1"
    )!
  }
}
