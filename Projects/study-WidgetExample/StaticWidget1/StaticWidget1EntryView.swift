//
//  StaticWidget1EntryView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/11/24.
//

import SwiftUI
import WidgetKit

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
                + Text(entry.date, style: .time)
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
                
                Text(entry.image?.urlString ?? "no url")
                
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
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct StaticWidget1EntryView_Previews: PreviewProvider {
    static var previews: some View {
        StaticWidget1EntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
