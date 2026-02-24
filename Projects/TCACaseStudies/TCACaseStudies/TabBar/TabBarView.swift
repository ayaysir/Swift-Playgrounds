//
//  TabBarView.swift
//  TCACaseStudies
//
//  Created by 윤범태 on 2/4/26.
//

import SwiftUI

struct TabBarView: View {
  enum TabMenu: String, CaseIterable {
    case home = "홈"
    case tour = "투어"
    case gallery = "갤러리"
    case profile = "프로필"
    
    var systemImage: String {
      switch self {
      case .home: "house"
      case .tour: "map"
      case .gallery: "photo"
      case .profile: "person"
      }
    }
  }
  
  @State private var tab: TabMenu = .gallery
  
  var body: some View {
    Text("\(tab)")
    TabView(selection: $tab) {
      
      // 각 탭 아이콘을 클릭했을 때 표시할 뷰
      ForEach(TabMenu.allCases, id: \.self) { tab in
        Tab(tab.rawValue, systemImage: tab.systemImage, value: tab) {
          CustomView(of:  tab)
        }
      }
      
      // ForEach(TabMenu.allCases, id: \.self) { tab in
      //   // 각 탭 아이콘을 클릭했을 때 표시할 뷰
      //   CustomView(of: tab)
      //     // 라벨과 태그 조합
      //     .tabItem {
      //       Label(tab.rawValue, systemImage: tab.systemImage)
      //         // ForEach(..id:) 사용시
      //         // .tag(tab) ForEach문을 통해 id가 부여되므로
      //         // 태그를 달지 않아도 됨
      //     }
      // }
      
      // CustomView(of: .home)
      //   .tabItem {
      //     Label(Tab.home.rawValue, systemImage: Tab.home.systemImage)
      //   }
      //   .tag(Tab.home)
      // 
      // CustomView(of: .tour)
      //   .tabItem {
      //     Label(Tab.tour.rawValue, systemImage: Tab.tour.systemImage)
      //     
      //   }
      //   .tag(Tab.tour)
      // 
      // CustomView(of: .gallery)
      //   .tabItem {
      //     Label(Tab.gallery.rawValue, systemImage: Tab.gallery.systemImage)
      //   }
      //   .tag(Tab.gallery)
      // 
      // CustomView(of: .profile)
      //   .tabItem {
      //     Label(Tab.profile.rawValue, systemImage: Tab.profile.systemImage)
      //   }
      //   .tag(Tab.profile)
    }
  }
  
  @ViewBuilder private func CustomView(of: TabMenu) -> some View {
    VStack {
      Spacer()
      Image(systemName: tab.systemImage)
        .font(.system(size: 30))
      Text(verbatim: tab.rawValue)
        .bold()
    }
    .foregroundStyle(.pink)
    .padding(20)
  }
}

#Preview {
  TabBarView()
}
