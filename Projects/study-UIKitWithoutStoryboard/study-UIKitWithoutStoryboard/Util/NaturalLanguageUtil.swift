//
//  NaturalLanguageUtil.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 1/30/26.
//

import NaturalLanguage

// 유틸리티 함수들을 외부 클래스/구조체로 분리해서 관리하고 싶을 경우 가장 추천하는 방법은
// struct + static 메서드 (상태 없음)

struct NaturalLanguageUtil {
  /// 언어 감지: 가장 확률이 높은 언어
  static func detectLanguage(of text: String) -> NLLanguage? {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    return recognizer.dominantLanguage
  }
  
  /// 언어 감지: 확률이 높은 `maxCount`개의 언어
  static func detectLanguages(
    of text: String,
    maxCount: Int = 3
  ) -> [NLLanguage: Double] {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    return recognizer.languageHypotheses(withMaximum: maxCount)
  }
  
  /// 현지화된(그 현지 아님) 언어 이름 반환
  static func localizedLanguageName(
    for language: NLLanguage,
    locale: Locale = .current
  ) -> String {
    locale.localizedString(forLanguageCode: language.rawValue)
    ?? language.rawValue
  }
  
  /// 언어 코드(raw) 반환
  static func languageCode(for language: NLLanguage) -> String {
    return language.rawValue
  }
}
