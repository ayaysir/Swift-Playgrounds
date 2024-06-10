//
//  CategoryHome.swift
//  Landmarks
//
//  Created by 윤범태 on 2023/11/12.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI

struct CategoryHome: View {
    @Environment(ModelData.self) var modelData
    
    var body: some View {
        NavigationSplitView {
            List {
                modelData.features[0].image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                // Set the edge insets to zero on both kinds of landmark previews so the content can extend to the edges of the display.
                    .listRowInsets(EdgeInsets())
                
                ForEach(modelData.categories.keys.sorted(), id: \.self) { key in
                    CategoryRow(categoryName: key, items: modelData.categories[key]!)
                }
                // Set the edge insets to zero on both kinds of landmark previews so the content can extend to the edges of the display.
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("Featured")
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    CategoryHome()
        .environment(ModelData())
}
