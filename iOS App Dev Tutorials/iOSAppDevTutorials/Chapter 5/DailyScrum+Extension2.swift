//
//  DailyScrum+Extension2.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import Foundation

extension DailyScrum {
    static var emptyScrum: DailyScrum {
        DailyScrum(title: "", attendees: [], lengthInMinutes: 5, theme: .sky)
    }
    
    var lengthInMinutesAsDouble: Double {
        get {
            Double(lengthInMinutes)
        }
        set {
            lengthInMinutes = Int(newValue)
        }
    }
}
