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
      HStack {
        Text("프로듀스 방침 효과 확인")
          .font(.title2)
          .bold()
      }
      Divider()
      AreaEffectList
      Button {
        store.send(.dismiss)
      } label: {
        Text("닫기")
          .frame(maxWidth: .infinity)
      }
      // .frame(maxWidth: .infinity)
      .buttonStyle(.bordered)
    }
    .padding(10)
  }
}

extension DetailSheetView {
  @ViewBuilder private func CellCourseEffect(of effect: CourseEffect) -> some View {
    HStack {
      // TODO: - 소지 여부에 따라 텍스트 표시 결정
      Text(Bool.random() ? "해방됨" : "")
        .frame(width: 50)
      VStack {
        HStack {
          CommonFrags.RoundedLabel("Lv\(effect.level)")
          Text(store.course.descJa.replacingOccurrences(of: "xx", with: effect.valueEffect.description))
        }
      }
    }
  }
  
  @ViewBuilder private var AreaEffectList: some View {
    List {
      HStack {
        let categoryString = store.course.category
        CommonFrags.RoundedLabel(
          categoryString,
          backgroundColor: Category(rawValue: categoryString)?.bgColor ?? .gray
        )
        Text(verbatim: store.course.titleJa)
          .bold()
      }
      HStack {
        CommonFrags.RoundedLabel("효과")
        Text(verbatim: "효과를 설명 (desc와 다름)")
          .font(.system(size: 13))
      }
      ForEach(store.course.effects) { effect in
        CellCourseEffect(of: effect)
          .font(.system(size: 13))
      }
    }
    .listStyle(.plain)
  }
}

#Preview {
  DetailSheetView(
    store: .init(
      initialState: DetailSheetDomain.State(course: .samples[0]),
      reducer: { DetailSheetDomain() }
    )
  )
}
