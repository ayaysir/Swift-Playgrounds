//
//  GlobalVariables.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/28/25.
//

import Foundation
import SwiftUI

// MARK: - Typealiases


// MARK: - NSNotiNames

extension NSNotification.Name {
    static let MIDIKey = Notification.Name("MIDIKey")
}

// MARK: - System variables

let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
