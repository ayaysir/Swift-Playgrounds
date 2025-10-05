//
//  DetailSheetDomain.swift
//  study-HousinPlannerTCA
//
//  Created by 윤범태 on 10/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DetailSheetDomain {
  @ObservableState
  struct State: Equatable {
    var course: Course
    var adjustLevelState: AdjustLevelDomain.State
    var locale: PlannerLocale = .ja
  }
  
  enum Action: Equatable {
    case dismiss
    case adjustLevel(AdjustLevelDomain.Action)
    case receiveLocaleChanged(PlannerLocale)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .dismiss:
        return .none
      case .adjustLevel(_):
        return .none
      case .receiveLocaleChanged(let locale):
        state.locale = locale
        return .none
      }
    }
  }
}

extension DetailSheetDomain.State {
  var courseTitleText: String {
    switch locale {
    case .ja: course.titleJa
    case .ko: course.titleKo
    }
  }
  
  func effectText(_ valueEffectDescription: String) -> String {
    let descRaw = switch locale {
    case .ja: course.descJa
    case .ko: course.descKo
    }
    
    return descRaw.replacingOccurrences(of: "xx", with: valueEffectDescription)
  }
  
  func appLocaleText(_ key: String) -> String {
    let dictText = """
      keyName,ja,ko
      sheetTitle,プロデュース方針効果確認,프로듀스 방침 효과 확인
      obtained,解放済,해방됨
      effect,效果,효과
      close,閉じる,닫기
      """
    return AppLocaleTextProvider.localizedText(
      dictText: dictText,
      for: key,
      locale: locale
    )
  }
}
