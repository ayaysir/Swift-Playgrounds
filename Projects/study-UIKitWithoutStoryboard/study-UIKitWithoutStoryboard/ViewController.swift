//
//  ViewController.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 1/24/26.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    // 서브 뷰 추가
    view.addSubview(hStack)
    view.addSubview(webView)
    
    // 제약 설정
    NSLayoutConstraint.activate([
      hStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      hStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      hStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
      searchButton.widthAnchor.constraint(equalToConstant: 40),
      // webView
      webView.topAnchor.constraint(equalTo: hStack.bottomAnchor, constant: 16),
      webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                      
    ])
    
    // 액션 연결
    searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
    
    // 딜리게이트
    textField.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    textField.becomeFirstResponder()
  }
  
  // MARK: - Actions
  @objc func didTapSearch() {
    guard let term = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
          !term.isEmpty else {
      return
    }
    
    print()
    
    
    let dictVC = UIReferenceLibraryViewController(term: term)
    textField.resignFirstResponder() // !! 키보드 사라지게 하기
    present(dictVC, animated: true)
    moveDictPage(for: term)
  }
  
  // MARK: - Methods
  
  private func moveDictPage(for term: String) {
    guard let language = NaturalLanguageUtil.detectLanguage(of: term) else {
      return
    }
    
    let languageCode = NaturalLanguageUtil.languageCode(for: language)
    
    let dictURLString = switch languageCode {
    case "en", "ja", "ko":
      "https://\(languageCode).dict.naver.com/#/search?query=\(term)&range=all"
    case "es", "fr", "de", "it", "pt", "ru", "ar":
      "https://dict.naver.com/\(languageCode)kodict/#/search?query=\(term)"
    case let code where code.hasPrefix("zh"):
      "https://ja.dict.naver.com/#/search?query=\(term)&range=all"
    default:
      "https://dict.naver.com/dict.search?query=\(term)"
    }
    
    if let dictURL = URL(string: dictURLString) {
      webView.load(URLRequest(url: dictURL))
    }
  }
  
  // MARK: - UI elements

  private let textField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    return textField
  }()
  
  private let searchButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("찾기", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  /*
   Swift 규칙상:
     •  let / var stored property 초기화 시점에는
     •  self를 참조할 수 없습니다

   그런데 textField, searchButton는 self의 프로퍼티이므로,
   일반 let 프로퍼티로는 아래 코드가 컴파일 자체가 불가능합니다.
   
   lazy var는 객체가 완전히 초기화된 이후,
   처음 접근하는 시점에 실행됩니다.

   즉:
     •  self 초기화 완료
     •  textField, searchButton 이미 존재
     •  따라서 참조 가능

   그래서 lazy가 필요합니다.
   */
  
  private lazy var hStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [textField, searchButton])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let webView: WKWebView = {
    let webView = WKWebView()
    webView.translatesAutoresizingMaskIntoConstraints = false
    let url = URL(string: "https://dict.naver.com")!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true

    return webView
  }()
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    didTapSearch()
    return true
  }
}

import SwiftUI
#Preview {
  UIViewControllerPreview {
    ViewController()
  }
}
