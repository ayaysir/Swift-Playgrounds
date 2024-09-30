//
//  ContentView.swift
//  study-BackgroundTasks
//
//  Created by 윤범태 on 9/30/24.
//

import SwiftUI
import SwiftData
import BackgroundTasks

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  
  var body: some View {
    NavigationSplitView {
      List {
        ForEach(items) { item in
          NavigationLink {
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
          } label: {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
          }
        }
        .onDelete(perform: deleteItems)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
        ToolbarItem {
          Button("App Fetch") {
            let request = BGAppRefreshTaskRequest(identifier: "com.example.refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 5)
            do {
              try BGTaskScheduler.shared.submit(request)
              /*
               lldb
               expression -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.example.refresh"]
               */
              print("AppFetch button pressed: \(Date.now)")
            } catch {
              print("AppFetch Error:", error)
            }
          }
        }
      }
    } detail: {
      Text("Select an item")
    }
  }
  
  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }
  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
