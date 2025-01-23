//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

class ContextDividerViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 배경색 설정
    view.backgroundColor = .systemBackground
    
    // 1. 메뉴에 들어갈 액션 생성
    /*
     결과는
     
     One
     Two
     
     로 표시됨
     */
    let topActions = [
      UIAction(title: "Two", image: UIImage(systemName: "2.square"), handler: { (_) in
        print("Two selected")
      }),
      UIAction(title: "One", image: UIImage(systemName: "1.square"), handler: { (_) in
        print("One selected")
      })
    ]
    
    // 2. 구분선 역할을 하는 메뉴 생성
    let divider = UIMenu(title: "", options: .displayInline, children: topActions)
    
    // 3. 구분선 아래에 들어갈 액션 생성
    let bottomAction = UIAction(title: "Three", image: UIImage(systemName: "3.square"), handler: { (_) in
      print("Three selected")
    })
    
    // 4. 메뉴에 들어갈 항목 설정
    let items = [divider, bottomAction]
    
    // 5. 최종적으로 표시될 메뉴 생성
    /*
     결과는
     
     Three
     ------
     One
     Two
     
     로 표시됨
     */
    
    let menu = UIMenu(title: "Menu", children: items)
    
    // 6. '메뉴 표시' 버튼 생성
    let button = UIButton(configuration: .borderedProminent())
    button.setTitle("메뉴 표시", for: .normal)
    button.showsMenuAsPrimaryAction = true // 메뉴를 기본 동작으로 설정
    button.menu = menu
    
    // 7. 버튼을 뷰에 추가
    view.addSubview(button)
    
    // 8. 버튼의 제약 조건 설정 (화면 한가운데에 위치하게)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
  }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ContextDividerViewController()
