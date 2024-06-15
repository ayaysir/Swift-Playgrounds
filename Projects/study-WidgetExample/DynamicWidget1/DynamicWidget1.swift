//
//  DynamicWidget1.swift
//  DynamicWidget1
//
//  Created by 윤범태 on 6/15/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct DynamicWidget1: Widget {
    let kind: String = "DynamicWidget1"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DynamicWidget1EntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                
        }
        .configurationDisplayName("Dynamic Widget 1")
        .description("👑 다이내믹 위젯 1 디스크립션")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct DynamicWidget2: Widget {
    let kind: String = "DynamicWidget2"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Text("widget2")
                
        }
        .configurationDisplayName("Dynamic Widget 2")
        .description("🦋 다이내믹 위젯 2 디스크립션")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemMedium) {
    DynamicWidget1()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
