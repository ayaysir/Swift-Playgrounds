//
//  SongCellDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 12/9/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SongCellDomain {
  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID = UUID()
    let info: SongInfo
    var beatmapInfo: LiveInfo? = nil  // 현재 선택된 난이도에 따라 표시될 정보
    var highlight: Bool = false          // 셀 강조 여부
    var difficulty: BeatmapDifficulty    // 부모에서 전달
  }

  enum Action: Equatable {
    case setHighlight(Bool)
    case setDifficulty(BeatmapDifficulty)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .setHighlight(let flag):
        state.highlight = flag
        return .none
      case .setDifficulty(let difficulty):
        state.difficulty = difficulty
        state.beatmapInfo = state.info.liveInfos.first { $0.difficulty == difficulty }
        return .none
      }
    }
  }
}
