//
//  LandmarkDetail.swift
//  SwiftUITutorial-Chapter123
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

struct LandmarkDetail: View {
    @Environment(ModelData.self) var modelData
    var landmark: Landmark
    
    var landmarkIndex: Int {
        modelData.landmarks.firstIndex {
            $0.id == landmark.id
        }!
    }
    
    var body: some View {
        /*
         Inside the body property, add the model data using a Bindable wrapper. Embed the landmark’s name in an HStack with a new FavoriteButton; provide a binding to the isFavorite property with the dollar sign ($).

         Use landmarkIndex with the modelData object to ensure that the button updates the isFavorite property of the landmark stored in your model object.
         */
        @Bindable var modelData = modelData
        
        VStack {
            MapView2(coordinate: landmark.locationCoordinate)
                .frame(height: 300)
            
            CircleImage2(image: landmark.image)
                .offset(y: -130)
                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(landmark.name)
                        .font(.title)
                    FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
                }
                HStack {
                    Text(landmark.park)
                    Spacer()
                    Text(landmark.state)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                Divider()
                
                Text("About \(landmark.name)")
                    .font(.title2)
                Text(landmark.description)
            }
            .padding()
        }
        .navigationTitle(landmark.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let modelData = ModelData()
    return LandmarkDetail(landmark: modelData.landmarks[0])
        .environment(modelData)
}
