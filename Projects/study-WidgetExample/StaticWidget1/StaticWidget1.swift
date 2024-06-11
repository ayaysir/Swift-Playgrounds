//
//  StaticWidget1.swift
//  StaticWidget1
//
//  Created by 윤범태 on 6/11/24.
//

import WidgetKit
import SwiftUI
import Intents

/*
 ** iOS 15.0 호환 **
 CongifurationIntent 생성 방법
  1. 위젯 프로젝트에서 New File > Siri Intents 어쩌고
  2. Configuration 인텐트 생성 > 카테고리 Information - View
  3. 빌드 (반드시 성공해야 자동 클래스 생성 => 타깃 17.x인 상태에서 먼저 인텐트를 생성하고 빌드 성공한 뒤, 타깃 버전다운 작업 진행)
  4. import Intents
 */

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            await completion(timeline(for: configuration, in: context))
        }
    }

    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
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
    let configuration: ConfigurationIntent
}

struct StaticWidget1EntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
        }
    }
}

struct StaticWidget1: Widget {
    let kind: String = "StaticWidget1"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            StaticWidget1EntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("** Static Widget 1")
        .description("** This is an example widget.")
    }
}

struct StaticWidget1EntryView_Previews: PreviewProvider {
    static var previews: some View {
        StaticWidget1EntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

/*
 ============= 17.0 이상 전용 =============
 */

// struct Provider: AppIntentTimelineProvider {
//     func placeholder(in context: Context) -> SimpleEntry {
//         SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
//     }
// 
//     func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//         SimpleEntry(date: Date(), configuration: configuration)
//     }
//     
//     func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//         var entries: [SimpleEntry] = []
// 
//         // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//         let currentDate = Date()
//         for hourOffset in 0 ..< 5 {
//             let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//             let entry = SimpleEntry(date: entryDate, configuration: configuration)
//             entries.append(entry)
//         }
// 
//         return Timeline(entries: entries, policy: .atEnd)
//     }
// }
// 
// struct SimpleEntry: TimelineEntry {
//     let date: Date
//     let configuration: ConfigurationAppIntent
// }
// 
// struct StaticWidget1EntryView : View {
//     var entry: Provider.Entry
// 
//     var body: some View {
//         VStack {
//             Text("Time:")
//             Text(entry.date, style: .time)
// 
//             Text("Favorite Emoji:")
//             Text(entry.configuration.favoriteEmoji)
//         }
//     }
// }
// 
// struct StaticWidget1: Widget {
//     let kind: String = "StaticWidget1"
// 
//     var body: some WidgetConfiguration {
//         AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//             StaticWidget1EntryView(entry: entry)
//                 .containerBackground(.fill.tertiary, for: .widget)
//         }
//     }
// }
// 
// extension ConfigurationAppIntent {
//     fileprivate static var smiley: ConfigurationAppIntent {
//         let intent = ConfigurationAppIntent()
//         intent.favoriteEmoji = "😀"
//         return intent
//     }
//     
//     fileprivate static var starEyes: ConfigurationAppIntent {
//         let intent = ConfigurationAppIntent()
//         intent.favoriteEmoji = "🤩"
//         return intent
//     }
// }
// 
// #Preview(as: .systemSmall) {
//     StaticWidget1()
// } timeline: {
//     SimpleEntry(date: .now, configuration: .smiley)
//     SimpleEntry(date: .now, configuration: .starEyes)
// }
