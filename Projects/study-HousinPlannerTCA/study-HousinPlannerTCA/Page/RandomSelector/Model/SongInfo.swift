//
//  SongInfo.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import Foundation

struct SongInfo: Codable, Equatable, Identifiable {
  let id: UUID
  // 曲名,idol_type,種類,category
  let title: String
  var titleSorter: String
  let type: String
  let category: String
  var liveInfos: [LiveInfo]
  
  private var noteCache: [BeatmapDifficulty: Int] = [:]
  private var gradeCache: [BeatmapDifficulty: Int] = [:]
  
  init(
    id: UUID,
    title: String,
    titleSorter: String,
    type: String,
    category: String,
    liveInfos: [LiveInfo]
  ) {
    self.id = id
    self.title = title
    self.titleSorter = titleSorter
    self.type = type
    self.category = category
    self.liveInfos = liveInfos
    liveInfos.forEach { info in
      noteCache[info.difficulty] = info.note
      gradeCache[info.difficulty] = info.grade
    }
  }
}

extension SongInfo {
  func liveInfo(for difficulty: BeatmapDifficulty) -> LiveInfo? {
    liveInfos.first { $0.difficulty == difficulty }
  }
  
  func grade(for difficulty: BeatmapDifficulty) -> Int {
    gradeCache[difficulty, default: .max]
  }
  
  func note(for difficulty: BeatmapDifficulty) -> Int {
    noteCache[difficulty, default: .max]
  }
}
