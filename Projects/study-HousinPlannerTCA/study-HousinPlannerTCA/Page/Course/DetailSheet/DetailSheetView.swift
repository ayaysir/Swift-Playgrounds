//
//  DetailSheetView.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/2/25.
//

import SwiftUI
import ComposableArchitecture

struct DetailSheetView: View {
  let store: StoreOf<DetailSheetDomain>
  
  var body: some View {
    VStack(alignment: .leading){
      AreaHeader
      Divider()
      AreaEffectList
      AreaCloseButton
    }
    .padding(10)
  }
}

extension DetailSheetView {
  @ViewBuilder private func CellCourseEffect(of effect: CourseEffect) -> some View {
    HStack {
      let showObtained = effect.level <= store.adjustLevelState.level
      let obtainedText = showObtained ? store.state.appLocaleText("obtained") : ""
      Text(obtainedText)
        .frame(width: 50)
        .foregroundStyle(.pink)
        .fontWeight(.semibold)
      VStack {
        HStack {
          CommonFrags.RoundedLabel("Lv\(effect.level)")
          Text(
            store.state.effectText(effect.valueEffect.description)
          )
        }
      }
    }
  }
  
  @ViewBuilder private var AreaHeader: some View {
    HStack {
      Text(verbatim: store.state.appLocaleText("sheetTitle"))
        .font(.title2)
        .bold()
    }
    .padding(.horizontal, 10)
    .padding(.top, 10)
  }
  
  @ViewBuilder private var AreaEffectList: some View {
    List {
      HStack {
        let categoryString = store.course.category
        CommonFrags.RoundedLabel(
          categoryString,
          backgroundColor: Category(rawValue: categoryString)?.bgColor ?? .gray
        )
        Text(verbatim: store.courseTitleText)
          .bold()
      }
      HStack {
        CommonFrags.RoundedLabel(store.state.appLocaleText("effect"))
        Text(verbatim: "레벨에 따라 다음 효과 발생")
          .font(.system(size: 13))
      }
      ForEach(store.course.effects) { effect in
        CellCourseEffect(of: effect)
          .font(.system(size: 13))
      }
    }
    .listStyle(.plain)
  }
  
  @ViewBuilder var AreaCloseButton: some View {
    Button {
      store.send(.dismiss)
    } label: {
      Text(verbatim: store.state.appLocaleText("close"))
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bordered)
  }
}

#Preview {
  DetailSheetView(
    store: .init(
      initialState: DetailSheetDomain.State(
        course: .samples[0],
        adjustLevelState: .init(level: 1)
      ),
      reducer: {
        DetailSheetDomain()
      }
    )
  )
}
