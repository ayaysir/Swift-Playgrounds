//
//  SimpleEntry.swift
//  StaticWidget1Extension
//
//  Created by 윤범태 on 6/11/24.
//

import WidgetKit

// *TimelineEntry: 위젯을 표시할 Date를 정하고, 그 Data에 표시할 데이터를 나타냄
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}
