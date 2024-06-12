//
//  StaticWidget1EntryView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import SwiftUI
import WidgetKit
import AppIntents

struct StaticWidget1EntryView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry
    
    private var randomColor: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
    
    private func percentEcododedString(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var body: some View {
        ZStack {
            if let uiImage = entry.image?.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.4)
            } else {
                randomColor.opacity(0.7)
            }
            
            VStack {
                Text("EntryDate:")
                    .bold()
                + (entry.configuration.isDisplayTimestampFormat == 1 ? Text(entry.date.timeIntervalSince1970.description) : Text(entry.date, style: .date))
                Text("Facts:")
                    .bold()
                if let texts = entry.configuration.texts {
                    ForEach(texts, id: \.hashValue) { text in
                        Text(text)
                            .font(.system(size: 12))
                        // 딥링크 URL 송신
                            .widgetURL(.init(string: percentEcododedString("widget://deeplink?text=\(text)")))
                    }
                }
                
                Text(entry.configuration.favoriteEmoji ?? "❌") + Text(entry.image?.urlString ?? "no url")
                    .font(.system(size: 8))
                
                if #available(iOS 17.0, *) {
                    Button(intent: UpdateCounterIntent()) {
                        Text("새로고침 및 카운터 1 증가")
                    }
                    Text("Counter 1: \(Counter.currentCount())")
                }
                
                switch family {
                case .systemSmall:
                    Text(".systemSmall")
                case .systemMedium:
                    Text(".systemMedium")
                case .systemLarge:
                    Text(".systemLarge")
                case .systemExtraLarge:
                    Text(".systemExtraLarge")
                case .accessoryCorner:
                    Text(".accessoryCorner")
                case .accessoryCircular:
                    Text(".accessoryCircular")
                case .accessoryRectangular:
                    Text(".accessoryRectangular")
                case .accessoryInline:
                    Text(".accessoryInline")
                @unknown default:
                    Text("@unknown default")
                }
            }
        }
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct UpdateCounterIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "카운터 증가"
    static var description = IntentDescription("카운터 1 증가")
    
    func perform() async throws -> some IntentResult {
        Counter.incrementCount()
        return .result()
    }
}

@available(iOS 17.0, *)
struct StaticWidget1EntryView_Previews: PreviewProvider {
    static var previews: some View {
        StaticWidget1EntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .containerBackground(.fill.tertiary, for: .widget)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
