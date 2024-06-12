//
//  Counter.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/12/24.
//

import Foundation

class Counter {
    // suite: 앱-익스텐션간 저장소를 공유하는 방법
    private static let sharedDefaults: UserDefaults = UserDefaults(suiteName: "group.examples.sjc")!
    
    static func incrementCount() {
        var count = sharedDefaults.integer(forKey: "count")
        count += 1
        sharedDefaults.set(count, forKey: "count")
    }
    
    static func currentCount() -> Int {
        sharedDefaults.integer(forKey: "count")
    }
}
