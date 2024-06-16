//
//  AppIntent.swift
//  DynamicWidget1
//
//  Created by 윤범태 on 6/15/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}

struct OpenAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "카운터 증가"
    static var description = IntentDescription("카운터 1 증가")
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
