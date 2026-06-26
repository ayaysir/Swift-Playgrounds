//
//  DictViewController.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 1/24/26.
//

import UIKit
import WebKit

final class DictViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    if #available(iOS 26, *) {
      let interaction = UIScrollEdgeElementContainerInteraction()
      interaction.scrollView = webView.scrollView
      interaction.edge = .bottom
      tabBarController?.tabBar.addInteraction(interaction)
    }
    
    // 서브 뷰 추가
    view.addSubview(headerHStack)
    view.addSubview(webView)
    
    // 뷰 세팅
    attachClearButtonToTextField()
    
    // 제약 설정
    NSLayoutConstraint.activate([
      // HStack
      headerHStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      headerHStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
      headerHStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      // 검색 버튼
      searchButton.widthAnchor.constraint(equalToConstant: 50),
      
      // webView
      webView.topAnchor.constraint(equalTo: headerHStack.bottomAnchor, constant: 16),
      webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      // webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                      
    ])
    
    webView.scrollView.contentInsetAdjustmentBehavior = .never
    
    // 액션 연결
    searchButton.addTarget(self, action: #selector(didTapSearch), for: .touchUpInside)
    clearButtonForTextField.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
    
    // 딜리게이트
    textField.delegate = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !ProcessInfo.isPreview {
      textField.becomeFirstResponder()
    }
    
    
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      // Jekyll의 경우 ^ 꼭다리 버튼을 bottom: 4.625rem; 라는 수치를 줌
      // => 이렇게 하면 어디서도 높이 떠 있어 보이긴 하나 탭바 위에 나타나므로 괜찮
      // 네이버 영어사전의 경우 bottom: 16px;
      // => 사파리에서는 동적으로 bottom이 조절되나 WKWebView 사용시 탭바에 가려지고 이걸 해결하기 위한 관련 정보를 찾기도 어려움, 김생성한테 물어봐도 잘 모름
      let script = """
      var style = document.createElement('style');
      style.innerHTML = `
      .nav_wrap {
        bottom: calc(4.625rem + env(safe-area-inset-bottom)) !important;
      }
      `;
      document.head.appendChild(style);
      """
      self.webView.evaluateJavaScript(script)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let bottomInset = view.safeAreaInsets.bottom
    webView.scrollView.contentInset.bottom = bottomInset
    webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(
      top: 0,
      left: 0,
      bottom: bottomInset,
      right: 0
    )
  }
  
  // MARK: - Actions
  
  @objc func didTapSearch() {
    guard let text = textField.text, !text.isEmpty else {
      textField.resignFirstResponder()
      return
    }
    
    let term = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !term.isEmpty else {
      return
    }
    
    let dictVC = UIReferenceLibraryViewController(term: term)
    textField.resignFirstResponder() // !! 키보드 사라지게 하기
    present(dictVC, animated: true)
    moveDictPage(for: term)
  }
  
  @objc func didTapClear() {
    textField.text = ""
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
  
  private func attachClearButtonToTextField() {
    let container = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 20))
    container.addSubview(clearButtonForTextField)

    textField.rightView = container
    textField.rightViewMode = .whileEditing
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
  
  private let clearButtonForTextField: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    button.tintColor = .systemGray
    button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
    return button
  }()
  
  private let searchButton: UIButton = {
    let button = UIButton(type: .system)
    button.configuration = .filled()
    button.configuration?.baseBackgroundColor = .systemTeal
    button.configuration?.baseForegroundColor = .white
    button.configuration?.cornerStyle = .medium
    button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
      var container = container
      container.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
      return container
    }
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
  
  private lazy var headerHStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [textField, searchButton])
    stack.axis = .horizontal
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  private let webView: WKWebView = {
    let webView = WKWebView()
    webView.translatesAutoresizingMaskIntoConstraints = false
    // let url = URL(string: "https://en.dict.naver.com/#/entry/enko/39dceabbc43f48c1a7e0531b2ffe54e8")!
    // let url = URL(string: "https://ayaysir.github.io")!
    let url = URL(string: "https://en.dict.naver.com/#/search?range=example&query=\(DIFFICULT_WORDS.randomElement()!)")!
    webView.load(URLRequest(url: url))
    webView.allowsBackForwardNavigationGestures = true

    let userScript = WKUserScript(
      source: injectedScript("dict-custom"),
      injectionTime: .atDocumentEnd,
      forMainFrameOnly: true
    )

    webView.configuration.userContentController.addUserScript(userScript)
    webView.isInspectable = true
    
    return webView
  }()
}

extension DictViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    didTapSearch()
    return true
  }
}

class FullScreenWKWebView: WKWebView {
  override var safeAreaInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  }
}

import SwiftUI
#Preview {
  UIViewControllerPreview {
    MainTabBarController()
  }
}
