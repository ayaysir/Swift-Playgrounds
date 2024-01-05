//
//  SlideDebounce.swift
//  CombineDebounceThrottle
//
//  Created by 윤범태 on 2024/01/05.
//

import SwiftUI
import Combine

struct SliderDebounce: View {
    @State private var sliderValue: Double = 1.123456
    @State private var processValue: Double = 1.123456
    
    private let sliderPublisher = PassthroughSubject<Double, Never>()
    @State private var sliderChangedCount = 0
    @State private var processCount = 0
    
    
    var body: some View {
        VStack {
            Text("Slider Value[EditingChanged: \(sliderChangedCount)]: \(sliderValue)")
            Slider(value: $sliderValue,
                   in: 1...100,
                   onEditingChanged: { _ in
                sliderChangedCount += 1
            })
            
        }
        .padding()
    }

    private func 대충엄청무거운작업(value: Double) {
        // ...... //
        processValue = value
    }
}

#Preview {
    SliderDebounce()
}
