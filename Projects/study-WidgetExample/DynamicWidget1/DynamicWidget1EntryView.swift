//
//  DynamicWidget1EntryView.swift
//  study-WidgetExample
//
//  Created by 윤범태 on 6/15/24.
//

import SwiftUI

struct DynamicWidget1EntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Button(intent: OpenAppIntent()) {
                Text(entry.configuration.favoriteEmoji)
            }
            Link(destination: URL(string: "https://www.apple.com")!) {
                Text("go to apple")
            }
            Link(destination: URL(string: "https://www.google.com")!) {
                Image(systemName: "tray.fill")
            }
            
            ForEach(items, id: \.hash) { item in
                Link(destination: URL(string: "widget://deeplink?timestamp=\(item.timestamp!)")!) {
                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
            }
        }
        .onAppear {
            // items = PersistenceController.shared.fetchItems()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
