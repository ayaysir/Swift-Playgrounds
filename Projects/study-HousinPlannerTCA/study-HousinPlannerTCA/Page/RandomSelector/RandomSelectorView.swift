//
//  RandomSelectorView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 11/20/25.
//

import SwiftUI
import ComposableArchitecture

// MARK: - MAIN

struct RandomSelectorView: View {
  @Bindable var store: StoreOf<RandomSelectorDomain>
  @Environment(\.scenePhase) var scenePhase
  
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
      store.send(.onAppear)
    }
    .onDisappear {
      setOrientation(.all)
    }
    .onChange(of: scenePhase) {
      store.send(.scenePhaseChanged(scenePhase))
      store.send(.setLandscape(store.isLandscape))
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
      switch toggleAction {
      case .on:
        store.send(.toggleAllOn)
      case .off:
        store.send(.toggleAllOff)
      case .toggle:
        store.send(.toggleAllInvert)
      }
    }) {
      Text(verbatim: buttonText)
    }
    .buttonStyle(.bordered)
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
      Picker("Difficulty", selection: $store.currentBeatmapDifficulty.sending(\.setDifficulty)) {
        ForEach(BeatmapDifficulty.casesWithoutBasic) { grade in
          Text("\(grade.upperShortenDesc)")
            .tag(grade)
        }
      }
      .pickerStyle(.segmented)
      Button(action: {
        store.send(.toggleLandscape)
      }) {
        let imageName = if store.isLandscape {
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
      Toggle("全タイプ曲", isOn: Binding {
        store.filterTypeAll
      } set: {
        store.send(.setFilterType(of: .all, isOn: $0))
      })
      Toggle("キュート曲", isOn: Binding {
        store.filterTypeCute
      } set: {
        store.send(.setFilterType(of: .cute, isOn: $0))
      })
      Toggle("クール曲", isOn: Binding {
        store.filterTypeCool
      } set: {
        store.send(.setFilterType(of: .cool, isOn: $0))
      })
      Toggle("パッション曲", isOn: Binding {
        store.filterTypePassion
      } set: {
        store.send(.setFilterType(of: .passion, isOn: $0))
      })
    }
  }
  
  @ViewBuilder private var AreaToggleTypes: some View {
    HStack {
      ButtonToggleTypes(toggleAction: .on, buttonText: "전체 선택")
      ButtonToggleTypes(toggleAction: .off, buttonText: "전체 해제")
      ButtonToggleTypes(toggleAction: .toggle, buttonText: "선택 반전")
      Spacer()
      Picker("곡 정렬", selection: $store.currentSortSongs.sending(\.setSortSongs)) {
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
      Group {
        ButtonSubmit(buttonTitle: "결정", tint: .pink) {
          store.send(.submitRandom)
        }
        ButtonSubmit(buttonTitle: "867 이상\n(합계 아이콘)", tint: .purple) {
          store.send(.submitRandomWithLimit(867))
        }
      }
      .disabled(store.isAllFilterOff)
    }
  }
  
  @ViewBuilder private var AreaSongList: some View {
    ScrollViewReader { proxy in
      List {
        ForEach(store.scope(state: \.cells, action: \.cell)) { cellStore in
          // UUID를 ScrollViewId로 사용
          // 1. .id(...) 사용 (tag 쓰면 동작 안함)
          // 2. UUID.uuidString 사용 (안넣으면 동작 안함)
          // 3. String interpolaration은 안해도 됨
          SongCellView(store: cellStore)
            .id(cellStore.id.uuidString)
        }
      }
      .listStyle(.plain)
      .onChange(of: store.highlightSongCellId) {
        guard let highlightId = store.highlightSongCellId else {
          return
        }
        print("onChangeScrollTo: \(highlightId)")
        proxy.scrollTo(highlightId.uuidString, anchor: .center)
      }
      .onChange(of: store.currentBeatmapDifficulty) {
        store.send(.setHighlightID(nil))
        guard let firstID = store.state.cells.first?.id else {
          return
        }
        proxy.scrollTo(firstID.uuidString, anchor: .top)
      }
      .onChange(of: store.currentSortSongs) {
        store.send(.setHighlightID(nil))
        guard let firstID = store.state.cells.first?.id else {
          return
        }
        proxy.scrollTo(firstID.uuidString, anchor: .top)
      }
    }
  }
}

// MARK: - Funcs

#Preview {
  RandomSelectorView(
    store: Store(
      initialState: RandomSelectorDomain.State(),
      reducer: { RandomSelectorDomain() }
    )
  )
}


