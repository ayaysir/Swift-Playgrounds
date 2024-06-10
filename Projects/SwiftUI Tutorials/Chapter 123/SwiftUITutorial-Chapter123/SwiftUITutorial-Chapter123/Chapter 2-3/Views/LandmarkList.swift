//
//  LandmarkList.swift
//  SwiftUITutorial-Chapter123
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

struct LandmarkList: View {
    // 3: Handling user input
    @Environment(ModelData.self) var modelData
    @State private var showFavoritesOnly = false
    
    var filteredLandmarks: [Landmark] {
        modelData.landmarks.filter {
            (!showFavoritesOnly || $0.isFavorite)
        }
    }
    
    // 2. Building lists and navigation
    var body: some View {
        NavigationSplitView {
            List {
                // 3
                Toggle(isOn: $showFavoritesOnly, label: {
                    Text("Label")
                })
                
                ForEach(filteredLandmarks) { landmark in
                    NavigationLink {
                        LandmarkDetail(landmark: landmark)
                    } label: {
                        LandmarkRow(landmark: landmark)
                    }
                }
            }
            . navigationTitle("Landmark")
        } detail: {
            Text("Select a Landmark")
        }

        
    }
}

#Preview {
    LandmarkList()
        .environment(ModelData())
}
