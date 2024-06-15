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
            Text(entry.configuration.favoriteEmoji)
            
            ForEach(items, id: \.hash) { item in
                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
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
