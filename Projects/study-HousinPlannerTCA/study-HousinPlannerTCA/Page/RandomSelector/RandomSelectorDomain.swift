//
//  RandomSelectorDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import Foundation
import SwiftUI
import ComposableArchitecture

@Reducer
struct RandomSelectorDomain {
  @ObservableState
  struct State: Equatable {
    var allSongInfos: [SongInfo] = []
    var highlightSongCellId: UUID? = nil
    var currentBeatmapDifficulty: BeatmapDifficulty = .masterPlus
    var currentSortSongs: SortSongs = .default
    
    // 기존 AppStorage → TCA에서는 단순 Bool 값이 State로 들어감
    var filterTypeAll = true
    var filterTypeCute = true
    var filterTypeCool = true
    var filterTypePassion  = true
    var isLandscape = false

    // ScenePhase 관련
    var scenePhase: ScenePhase = .active
    
    // SongInfos
    var cells: IdentifiedArrayOf<SongCellDomain.State> = []
    
    var isAllFilterOff: Bool {
      [filterTypeAll, filterTypeCute, filterTypeCool, filterTypePassion].allSatisfy({ !$0 })
    }
  }
  
  enum Action: Equatable {
    case onAppear
    case scenePhaseChanged(ScenePhase)
    case toggleLandscape
    case setLandscape(Bool)
    
    case setDifficulty(BeatmapDifficulty)
    case setSortSongs(SortSongs)
    
    case setFilterType(of: SongType, isOn: Bool)
    
    case toggleAllOn
    case toggleAllOff
    case toggleAllInvert

    case submitRandom
    case submitRandomWithLimit(Int)
    
    case setHighlightID(UUID?)
    
    // CSV Parsing 작업
    case loadCSV
    case loadCSVResponse(TaskResult<[SongInfo]>)
    
    // SongInfos
    case cell(IdentifiedActionOf<SongCellDomain>)
    case generateCells
  }
  
  // Enter dependencies if exists...
  @Dependency(\.defaultAppStorage) var appStorage
  @Dependency(\.orientation) var orientation
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        // Enter cases...
      case .onAppear:
        // UserDefaults에 저장해둔 필터/정렬/난이도 값 불러오기
        return .run { send in
          let filterTypeAll = appStorage.bool(forKey: .cfgRsFilterTypeAll)
          let filterTypeCute = appStorage.bool(forKey: .cfgRsFilterTypeCute)
          let filterTypeCool = appStorage.bool(forKey: .cfgRsFilterTypeCool)
          let filterTypePassion = appStorage.bool(forKey: .cfgRsFilterTypePassion)
          let isLandscape = appStorage.bool(forKey: .cfgRsIsLandscape)
          
          await send(.setFilterType(of: .all, isOn: filterTypeAll))
          await send(.setFilterType(of: .cute, isOn: filterTypeCute))
          await send(.setFilterType(of: .cool, isOn: filterTypeCool))
          await send(.setFilterType(of: .passion, isOn: filterTypePassion))
          await send(.setLandscape(isLandscape))
          
          await send(.loadCSV)
        }
        
      case .scenePhaseChanged(let phase):
        // 단순 상태만 기록: 토글 또는 변경 없음
        state.scenePhase = phase
        return .none
        
      case .setLandscape(let value):
        state.isLandscape = value
        appStorage.set(value, forKey: .cfgRsIsLandscape)
        orientation.set(state.isLandscape ? .landscape : .portrait)
        return .none
        
      case .toggleLandscape:
        state.isLandscape.toggle()

        appStorage.set(state.isLandscape, forKey: .cfgRsIsLandscape)
        orientation.set(state.isLandscape ? .landscape : .portrait)
        return .none
        
      case .setDifficulty(let difficulty):
        state.currentBeatmapDifficulty = difficulty
        return .send(.generateCells)
        
      case .setSortSongs(let sort):
        state.currentSortSongs = sort
        return .send(.generateCells)
        
      case .setFilterType(of: let type, isOn: let value):
        var key: String
        switch type {
        case .all:
          state.filterTypeAll = value
          key = .cfgRsFilterTypeAll
        case .cute:
          state.filterTypeCute = value
          key = .cfgRsFilterTypeCute
        case .cool:
          state.filterTypeCool = value
          key = .cfgRsFilterTypeCool
        case .passion:
          state.filterTypePassion = value
          key = .cfgRsFilterTypePassion
        }
        
        appStorage.set(value, forKey: key)
        appStorage.synchronize()
        return .none
        
      case .toggleAllOn:
        return .run { send in
          await send(.setFilterType(of: .all, isOn: true))
          await send(.setFilterType(of: .cute, isOn: true))
          await send(.setFilterType(of: .cool, isOn: true))
          await send(.setFilterType(of: .passion, isOn: true))
        }
        
      case .toggleAllOff:
        return .run { send in
          await send(.setFilterType(of: .all, isOn: false))
          await send(.setFilterType(of: .cute, isOn: false))
          await send(.setFilterType(of: .cool, isOn: false))
          await send(.setFilterType(of: .passion, isOn: false))
        }
        
      case .toggleAllInvert:
        let state = state
        return .run { send in
          await send(.setFilterType(of: .all, isOn: !state.filterTypeAll))
          await send(.setFilterType(of: .cute, isOn: !state.filterTypeCute))
          await send(.setFilterType(of: .cool, isOn: !state.filterTypeCool))
          await send(.setFilterType(of: .passion, isOn: !state.filterTypePassion))
        }
        
      case .submitRandom:
        return .send(.setHighlightID(state.selectRandomID()))
        
      case .submitRandomWithLimit(let limit):
        return .send(.setHighlightID(state.selectRandomID(notesLimit: limit)))
        
      case .setHighlightID(let id):
        state.highlightSongCellId = id
        for index in state.cells.indices {
          state.cells[index].highlight = (state.cells[index].id == id)
        }
        return .none
        
      case .loadCSV:
        return .run { send in
           await send(
            .loadCSVResponse(
              TaskResult {
                parseCSVData()
              }
            )
           )
        }
      case .loadCSVResponse(.success(let allSongInfos)):
        state.allSongInfos = allSongInfos
        return .send(.generateCells)
        
      case .loadCSVResponse(.failure(let error)):
        print("CSV 파싱 오류:", error)
        state.allSongInfos = []
        return .none
        
      case .cell:
        return .none
        
      case .generateCells:
        generateSongCells(state: &state)
        return .none
      }
    }
    .forEach(\.cells, action: \.cell) {
      SongCellDomain()
    }
    // .ifLet(\.$cartState, action: \.cart) {}
  }
}

/*
 1.  View에 있는 모든 상태(@State, @AppStorage)를 State로 이동
 2.  View Event(버튼, Picker 변경, onAppear 등)를 Action으로 이동
 3.  도메인 로직(initData, selectRandomIndex)을 Reducer 내부로 이동
 4.  필터/정렬은 State의 계산속성으로 유지
 */

extension RandomSelectorDomain.State {
  func selectRandomID(
    notesLimit: Int? = nil
  ) -> UUID? {
    let filter = Set([
      filterTypeAll ? "全タイプ" : nil,
      filterTypeCute ? "キュート" : nil,
      filterTypeCool ? "クール" : nil,
      filterTypePassion ? "パッション" : nil,
    ].compactMap { $0 })
    
    for _ in 0..<1000 {
      let randomId = cells.randomElement()?.id ?? nil
      
      guard let randomId,
            let songInfo = cells.first(where: { $0.id == randomId }),
            let beatmapInfo = songInfo.beatmapInfo else {
        print("Error: cannot find beatmapInfo")
        return nil
      }
      
      // notesLimit가 nil 이 아니라면
      // beatmapInfo?.note >= notesLimit 인것만 추출
      if filter.contains(beatmapInfo.type) {
        if let notesLimit, beatmapInfo.note < notesLimit {
          continue
        }
        
        return randomId
      }
    }
    
    return nil
  }
}

extension RandomSelectorDomain {
  func parseCSVData() -> [SongInfo] {
    let songListCSV = parseCSV(bundleName: "song_list")
    let mpNotesCSV = parseCSV(bundleName: "MP Notes-MASTER+")
    let witchNotesCSV = parseCSV(bundleName: "MP Notes-WITCH")
    let pianoNotesCSV = parseCSV(bundleName: "MP Notes-PIANO")
    let forteNotesCSV = parseCSV(bundleName: "MP Notes-FORTE")
    let lightNotesCSV = parseCSV(bundleName: "MP Notes-LIGHT")
    let trickNotesCSV = parseCSV(bundleName: "MP Notes-TRICK")
    // print(songListCSV, mpNotesCSV)
    // print(songListCSV[0])
    
    return songListCSV.compactMap { resultArr in
      guard let title = resultArr[safe: 0],
            let type = resultArr[safe: 1],
            let category = resultArr[safe: 3],
            let titleSorter = resultArr[safe: 10] else {
        return nil
      }
      
      let liveInfos: [LiveInfo] = BeatmapDifficulty.casesWithoutBasic.compactMap { difficulty in
        let csvArray: [[String]]? = switch difficulty {
        case .masterPlus:
          mpNotesCSV
        case .witch:
          witchNotesCSV
        case .piano:
          pianoNotesCSV
        case .forte:
          forteNotesCSV
        case .light:
          lightNotesCSV
        case .trick:
          trickNotesCSV
        default:
          nil
        }
        
        guard let info: [String] = csvArray?.first(where: { infoArr in
          infoArr[safe: 1] == title
        }) else {
          return nil
        }
        
        return LiveInfo(fromCSVArray: info, difficulty: difficulty)
      }
      
      return SongInfo(
        id: .init(),
        title: title,
        titleSorter: titleSorter,
        type: type,
        category: category,
        liveInfos: liveInfos
      )
    }
  }
  
  func generateSongCells(state: inout Self.State) {
    let baseStates = state.allSongInfos.filter {
      $0.liveInfos.contains {
        $0.difficulty == state.currentBeatmapDifficulty
      }
    }.map {
      SongCellDomain.State(
        info: $0,
        beatmapInfo: $0.liveInfo(for: state.currentBeatmapDifficulty),
        highlight: false,
        difficulty: state.currentBeatmapDifficulty
      )
    }
    
    switch state.currentSortSongs {
      case .default:
      state.cells = IdentifiedArray(uniqueElements: baseStates)
      
      case .title:
        state.cells = IdentifiedArray(uniqueElements: baseStates.sorted(by: { lhs, rhs in
          lhs.info.titleSorter < rhs.info.titleSorter
        }))
      case .level:
        state.cells = IdentifiedArray(uniqueElements: baseStates.sorted(by: { lhs, rhs in
          lhs.beatmapInfo?.grade ?? .max < rhs.beatmapInfo?.grade ?? .min
        }))
      case .noteCount:
        state.cells = IdentifiedArray(uniqueElements: baseStates.sorted(by: { lhs, rhs in
          lhs.beatmapInfo?.note ?? .max < rhs.beatmapInfo?.note ?? .min
        }))
      
    }
  }
}
