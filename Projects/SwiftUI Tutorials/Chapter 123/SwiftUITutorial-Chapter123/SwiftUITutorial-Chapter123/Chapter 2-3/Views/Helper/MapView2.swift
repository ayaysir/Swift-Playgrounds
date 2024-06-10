//
//  MapView2.swift
//  SwiftUITutorial-Chapter123
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI
import MapKit

struct MapView2: View {
    var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(position: .constant(.region(region)))
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }
}

#Preview {
    MapView2(coordinate: .init(latitude: 34.011_286, longitude: -116.166_868))
}
