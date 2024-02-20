//
//  열려있는문은모두몇개View.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/12.
//

import SwiftUI

fileprivate let totalCount = 50

final class 열려있는문은모두몇개ViewModel: ObservableObject {
    @Published var doorStates: [Bool] = .init(repeating: false, count: totalCount)
    private var previousStates: [[Bool]] = []
    
    var answer: Int {
        Int(sqrt(Double(totalCount)))
    }
    
    func resetStates() {
        doorStates = .init(repeating: false, count: totalCount)
        previousStates = []
    }
    
    func progressStates(_ sceneNumber: Int) {
        guard sceneNumber > 0 else {
            resetStates()
            return
        }
        
        previousStates.append(doorStates)
        
        for i in 0..<totalCount where (i + 1) % sceneNumber == 0  {
            doorStates[i].toggle()
        }
    }
    
    func undoStates() {
        doorStates = previousStates.removeLast()
    }
}

struct 열려있는문은모두몇개View: View {
    private let MARGIN: CGFloat = 20
    
    // 화면을 그리드형식으로 꽉채워줌
    var columns: [GridItem] {
        return (1...5).map { _ in
            GridItem(.flexible(), spacing: MARGIN)
        }
    }
    
    @StateObject var viewModel = 열려있는문은모두몇개ViewModel()
    @State var sceneNumber = 0
    
    @State private var playButtonText = "play.fill"
    @State private var playButtonTimer: Timer?
    
    var body: some View {
        VStack {
            HStack {
                Stepper("[answer: \(viewModel.answer)] Scene \(sceneNumber)") {
                    guard sceneNumber < totalCount else {
                        return
                    }
                    
                    sceneNumber += 1
                    viewModel.progressStates(sceneNumber)
                } onDecrement: {
                    guard sceneNumber > 0 else {
                        return
                    }
                    
                    sceneNumber -= 1
                    viewModel.undoStates()
                }
                
                Button("", systemImage: playButtonText) {
                    guard playButtonText == "play.fill" else {
                        playButtonText = "play.fill"
                        playButtonTimer?.invalidate()
                        return
                    }
                    
                    sceneNumber = 0
                    viewModel.resetStates()
                    playButtonText = "pause.fill"
                    
                    playButtonTimer = .scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
                        sceneNumber += 1
                        viewModel.progressStates(sceneNumber)
                        
                        if sceneNumber == totalCount {
                            timer.invalidate()
                            playButtonText = "play.fill"
                        }
                    }
                }
            }
            
            LazyVGrid(columns: columns, spacing: MARGIN) {
                ForEach(viewModel.doorStates.indices, id: \.self) { index in
                    Rectangle()
                        .fill(.clear)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay {
                            Image(
                                systemName: "door.left.hand." + (viewModel.doorStates[index] ? "open" : "closed")
                            )
                            .resizable()
                            .foregroundStyle(viewModel.doorStates[index] ? .red : .gray)
                        }
                }
            }
        }
        .padding()
    }
}

#Preview {
    열려있는문은모두몇개View()
}
