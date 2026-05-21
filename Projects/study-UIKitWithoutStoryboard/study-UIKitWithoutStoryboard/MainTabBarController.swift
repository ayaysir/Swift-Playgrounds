//
//  MainTabBarController.swift
//  study-UIKitWithoutStoryboard
//
//  Created by 윤범태 on 3/19/26.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTabs()
  }
  
  private func setupTabs() {
    let dictVC = DictViewController()
    let shortformVC = ShortformViewController()
    
    // // (선택) NavigationController로 감싸기
    // let firstNav = UINavigationController(rootViewController: firstVC)
    // let secondNav = UINavigationController(rootViewController: secondVC)
    // let thirdNav = UINavigationController(rootViewController: thirdVC)
    
    dictVC.tabBarItem = UITabBarItem(title: "Home", image: .init(systemName: "house"), tag: 0)
    shortformVC.tabBarItem = UITabBarItem(title: "Search", image: .init(systemName: "magnifyingglass"), tag: 1)
    
    if #available(iOS 26.0, *) {
      tabBarMinimizeBehavior = .onScrollDown
      self.tabBar.isTranslucent = true
    } else {
      self.tabBar.isTranslucent = false
    }
    
    viewControllers = [dictVC, shortformVC, ShortformViewController(), ShortformViewController()]
  }
}

import SwiftUI

#Preview {
  UIViewControllerPreview {
    MainTabBarController()
  }
}
