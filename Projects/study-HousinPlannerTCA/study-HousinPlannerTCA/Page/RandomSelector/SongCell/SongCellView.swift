//
//  SongCellView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/9/25.
//

import SwiftUI
import ComposableArchitecture

struct SongCellView: View {
  let store: StoreOf<SongCellDomain>
  
  var body: some View {
    VStack {
      Text(store.info.title)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
      
      if let beatmapInfo = store.beatmapInfo {
        VStack {
          HStack(spacing: 0) {
            Text("☆ \(beatmapInfo.grade, default: "-")")
              .foregroundStyle(beatmapInfo.grade >= 30 ? .red : .primary)
              .bold(beatmapInfo.grade >= 30)
            Group {
              SongTextDividor
              Text("Notes: \(beatmapInfo.note, default: "-")")
                .foregroundStyle(beatmapInfo.note >= 1000 ? .red : .secondary)
              SongTextDividor
              Text("Type: ")
            }
            .foregroundStyle(.secondary)
            SongInfoTypeText(info: store.info)
          }
          .frame(maxWidth: .infinity, alignment: .trailing)
          
          HStack(spacing: 0) {
            Text("Long: \(beatmapInfo.long?.percentString, default: "-")")
              .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo.long))
            SongTextDividor
            Text("Flick: \(beatmapInfo.flick?.percentString, default: "-")")
              .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo.flick))
            SongTextDividor
            Text("Slide: \(beatmapInfo.slide?.percentString, default: "-")")
              .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo.slide))
          }
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.caption2)
      }
    }
    // .background(
    //   store.highlight
    //   ? Color.yellow.opacity(0.3)
    //   : Color(.systemBackground)
    // )
    .listRowBackground(
      store.highlight
      ? Color.yellow.opacity(0.3)
      : Color(.systemBackground)
    )
  }
  
  @ViewBuilder private var SongTextDividor: some View {
    Text(" | ")
  }
  
  @ViewBuilder private func SongInfoTypeText(info: SongInfo) -> some View {
    let typeColor: any ShapeStyle = switch info.type {
    case "All":
      LinearGradient(
        colors: [.red, .pink, .blue, .yellow, .orange],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    case "Cu": .pink
    case "Co": .blue
    case "Pa": .orange
    default: .secondary
    }
    
    Text(info.type)
      .bold()
      .foregroundStyle(typeColor) // ← 타입 값 색
  }
  
  private func SpecialNoteColor(percentage value: Double?) -> Color {
    guard let value else {
      return .secondary
    }
    
    return switch value {
    case 0.2..<0.3:
        .orange
    case 0.3..<0.4:
        .pink
    case 0.4...:
        .red
    default:
        .secondary
    }
  }
}

#Preview {
  SongCellView(
    store: Store(
      initialState: SongCellDomain.State(
        info: .init(
          id: UUID(),
          title: "Test Song",
          titleSorter: "test",
          type: "All",
          category: "",
          liveInfos: [
            LiveInfo(
              id: UUID(),
              title: "Test Song",
              difficulty: .masterPlus,
              type: "All",
              grade: 20,
              time: "2:23",
              note: 500,
              long: 0.2,
              flick: 0.2,
              slide: 0.2
            )
          ]
        ),
        beatmapInfo: LiveInfo(
          id: UUID(),
          title: "Test Song",
          difficulty: .masterPlus,
          type: "All",
          grade: 20,
          time: "2:23",
          note: 500,
          long: 0.2,
          flick: 0.2,
          slide: 0.6
        ),
        highlight: true,
        difficulty: .masterPlus
      ),
      reducer: { SongCellDomain()
      }
    )
  )
}
