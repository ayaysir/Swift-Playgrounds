//
//  RandomSelectorView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import SwiftUI
import ComposableArchitecture

fileprivate enum ToggleAction {
  case on, off, toggle
}

fileprivate enum SortSongs {
  case `default`, title, level, noteCount
}

// MARK: - MAIN

struct RandomSelectorView: View {
  // @Bindable var store: StoreOf<PlannerDomain>
  @Environment(\.scenePhase) var scenePhase
  @State private var infos: [SongInfo] = []
  @State private var highlightIndex: Int?
  @State private var currentBeatmapDifficulty: BeatmapDifficulty = .masterPlus
  @State private var currentSortSongs: SortSongs = .default
  
  @AppStorage("RS_CFG_filterTypeAll") private var filterTypeAll = true
  @AppStorage("RS_CFG_filterTypeCute") private var filterTypeCute = true
  @AppStorage("RS_CFG_filterTypeCool") private var filterTypeCool = true
  @AppStorage("RS_CFG_filterTypePassion") private var filterTypePassion = true
  @AppStorage("RS_CFG_isLandScape") private var isLandscape = false
  
  var filteredInfos: [SongInfo] {
    let base = infos.filter {
      $0.liveInfos.contains {
        $0.difficulty == currentBeatmapDifficulty
      }
    }
    
    switch currentSortSongs {
    case .default:
      return base
    case .title:
      return base
        .sorted { lhs, rhs in
          lhs.titleSorter < rhs.titleSorter
        }
    case .level:
      return base
        .sorted { lhs, rhs in
          lhs.grade(for: currentBeatmapDifficulty) < rhs.grade(for: currentBeatmapDifficulty)
        }
    case .noteCount:
      return base
        .sorted { lhs, rhs in
          lhs.note(for: currentBeatmapDifficulty) < rhs.note(for: currentBeatmapDifficulty)
        }
    }
  }
  
  let columns = Array(
    repeating: GridItem(.flexible(), spacing: 20),
    count: 2
  )
  
  var body: some View {
    responsiveLayout {
      VStack(spacing: 20) {
        AreaSelectGrade
        AreaSelectTypes
        AreaToggleTypes
        AreaSelectButtons
        AreaSongList
          .padding(.horizontal, -20)
      }
      .padding()
    } landscape: {
      HStack {
        VStack {
          AreaSelectGrade
            .padding(.top, 10)
          AreaSelectTypes
          AreaToggleTypes
          AreaSelectButtons
          Spacer()
        }
        AreaSongList
      }
    }
    .onAppear {
      initData()
      
      setOrientation(isLandscape ? .landscape : .portrait)
    }
    .onDisappear {
      setOrientation(.all)
    }
    .onChange(of: scenePhase) {
      switch scenePhase {
      case .active:
        setOrientation(isLandscape ? .landscape : .portrait)
      default:
        break
      }
    }
  }
}

// MARK: - Frags

extension RandomSelectorView {
  @ViewBuilder private var SongTextDividor: some View {
    Text(" | ")
  }
  @ViewBuilder private func ButtonSubmit(
    buttonTitle: String,
    tint: Color,
    completion: @escaping () -> Void = {}
  ) -> some View {
    Button(action: completion) {
      Text(verbatim: buttonTitle)
        .frame(maxWidth: .infinity)
        .frame(height: 30)
        .minimumScaleFactor(0.5)
    }
    .buttonStyle(.borderedProminent)
    .tint(tint)
  }
  
  @ViewBuilder private func ButtonToggleTypes(toggleAction: ToggleAction, buttonText: String) -> some View {
    Button(action: {
      [
        $filterTypeAll,
        $filterTypeCool,
        $filterTypeCute,
        $filterTypePassion
      ].forEach {
        $0.wrappedValue = switch toggleAction {
        case .on:
          true
        case .off:
          false
        case .toggle:
          !$0.wrappedValue
        }
      }
    }) {
      Text(verbatim: buttonText)
    }
    .buttonStyle(.bordered)
  }
  
  @ViewBuilder private func CellSongInfo(_ info: SongInfo) -> some View {
    VStack {
      Text(info.title)
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
      // TODO: 난이도에 따라 변경
      let beatmapInfo = info.liveInfos.first(where: { $0.difficulty == currentBeatmapDifficulty })
      VStack {
        HStack(spacing: 0) {
          Text("☆ \(beatmapInfo?.grade, default: "-")")
            .foregroundStyle(beatmapInfo?.grade ?? 0 >= 30 ? .red : .primary)
            .bold(beatmapInfo?.grade ?? 0 >= 30)
          Group {
            SongTextDividor
            Text("Notes: \(beatmapInfo?.note, default: "-")")
              .foregroundStyle(beatmapInfo?.note ?? 0 >= 1000 ? .red : .secondary)
            SongTextDividor
            Text("Type: ")
          }
          .foregroundStyle(.secondary)
          SongInfoTypeText(info: info)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        
        HStack(spacing: 0) {
          Text("Long: \(beatmapInfo?.long?.percentString, default: "-")")
            .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo?.long))
          SongTextDividor
          Text("Flick: \(beatmapInfo?.flick?.percentString, default: "-")")
            .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo?.flick))
          SongTextDividor
          Text("Slide: \(beatmapInfo?.slide?.percentString, default: "-")")
            .foregroundStyle(SpecialNoteColor(percentage: beatmapInfo?.slide))
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .font(.caption2)
    }
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
}

// MARK: - Areas

extension RandomSelectorView {
  @ViewBuilder private var AreaSelectGrade: some View {
    HStack {
      Picker("", selection: $currentBeatmapDifficulty) {
        ForEach(BeatmapDifficulty.casesWithoutBasic) { grade in
          Text("\(grade.upperShortenDesc)")
            .tag(grade)
        }
      }
      .pickerStyle(.segmented)
      Button(action: {
        setOrientation(isLandscape ? .portrait : .landscape)
        isLandscape.toggle()
      }) {
        let imageName = if isLandscape {
          "rectangle.portrait.rotate"
        } else {
          "rectangle.landscape.rotate"
        }
        
        Image(systemName: imageName)
      }
    }
  }
  
  @ViewBuilder private var AreaSelectTypes: some View {
    LazyVGrid(columns: columns, spacing: 20) {
      Toggle("全タイプ曲", isOn: $filterTypeAll)
      Toggle("キュート曲", isOn: $filterTypeCute)
      Toggle("クール曲", isOn: $filterTypeCool)
      Toggle("パッション曲", isOn: $filterTypePassion)
    }
  }
  
  @ViewBuilder private var AreaToggleTypes: some View {
    HStack {
      ButtonToggleTypes(toggleAction: .on, buttonText: "전체 선택")
      ButtonToggleTypes(toggleAction: .off, buttonText: "전체 해제")
      ButtonToggleTypes(toggleAction: .toggle, buttonText: "선택 반전")
      Spacer()
      Picker("곡 정렬", selection: $currentSortSongs) {
        Text("기본순")
          .tag(SortSongs.default)
        Text("악곡명순")
          .tag(SortSongs.title)
        Text("악곡Lv순")
          .tag(SortSongs.level)
        Text("리듬 아이콘순")
          .tag(SortSongs.noteCount)
      }
    }
  }
  
  @ViewBuilder private var AreaSelectButtons: some View {
    HStack {
      ButtonSubmit(buttonTitle: "결정", tint: .pink) {
        selectRandomIndex()
      }
      ButtonSubmit(buttonTitle: "867 이상\n(합계 아이콘)", tint: .purple) {
        selectRandomIndex(notesLimit: 867)
      }
    }
  }
  
  @ViewBuilder private var AreaSongList: some View {
    ScrollViewReader { proxy in
      List {
        ForEach(filteredInfos.indices, id: \.self) { i in
          CellSongInfo(filteredInfos[i])
            .tag(i)
            .listRowBackground(
              highlightIndex == i ?
              Color.yellow.opacity(0.3) :
                Color(.systemBackground)
            )
        }
      }
      .listStyle(.plain)
      .onChange(of: highlightIndex) {
        guard let highlightIndex else {
          return
        }
        
        proxy.scrollTo(highlightIndex, anchor: .center)
      }
      .onChange(of: currentBeatmapDifficulty) {
        highlightIndex = nil
        proxy.scrollTo(0, anchor: .top)
      }
      .onChange(of: currentSortSongs) {
        highlightIndex = nil
        proxy.scrollTo(0, anchor: .top)
      }
    }
  }
}

// MARK: - Funcs

extension RandomSelectorView {
  func initData() {
    let songListCSV = parseCSV(bundleName: "song_list")
    let mpNotesCSV = parseCSV(bundleName: "MP Notes-MASTER+")
    let witchNotesCSV = parseCSV(bundleName: "MP Notes-WITCH")
    let pianoNotesCSV = parseCSV(bundleName: "MP Notes-PIANO")
    let forteNotesCSV = parseCSV(bundleName: "MP Notes-FORTE")
    let lightNotesCSV = parseCSV(bundleName: "MP Notes-LIGHT")
    let trickNotesCSV = parseCSV(bundleName: "MP Notes-TRICK")
    // print(songListCSV, mpNotesCSV)
    // print(songListCSV[0])
    infos = songListCSV.compactMap { resultArr in
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
  
  func selectRandomIndex(notesLimit: Int? = nil) {
    let filter = Set([
      filterTypeAll ? "All" : nil,
      filterTypeCute ? "Cu" : nil,
      filterTypeCool ? "Co" : nil,
      filterTypePassion ? "Pa" : nil,
    ].compactMap { $0 })
    // print(filter)
    for _ in 0..<1000 {
      let randomTag = Int.random(in: 0..<filteredInfos.count)
      let songInfo = filteredInfos[randomTag]
      let maspLiveInfo = songInfo.liveInfos.first(where: { $0.difficulty == .masterPlus })
      
      // notesLimit가 nil 이 아니라면
      // maspLiveInfo?.note >= notesLimit 인것만 추출
      if filter.contains(filteredInfos[randomTag].type) {
        if let notesLimit,
           let note = maspLiveInfo?.note,
           note < notesLimit {
          continue
        }
        highlightIndex = randomTag
        break
      }
    }
  }
}

#Preview {
  RandomSelectorView()
}


