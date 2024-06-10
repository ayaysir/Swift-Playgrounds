//
//  Profile.swift
//  Landmarks
//
//  Created by 윤범태 on 2023/11/12.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

struct Profile {
    var username: String
    var prefersNotifications = true
    var seasonalPhoto = Season.winter
    var goalDate = Date()

    static let `default` = Profile(username: "g_kumar")
    /*
     To use a reserved word as an identifier, put a backtick (`)before and after it. For example, class is not a valid identifier, but `class` is valid. The backticks are not considered part of the identifier; `x` and x have the same meaning.
     */

    enum Season: String, CaseIterable, Identifiable {
        case spring = "🌷"
        case summer = "🌞"
        case autumn = "🍂"
        case winter = "☃️"

        var id: String { rawValue }
    }
}

