//
//  에라토스테네스의체View.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2/21/24.
//

import SwiftUI

fileprivate let totalCount = 200

private struct Box {
    var value: Int = 0
    var fillColor: Color?
}

struct 에라토스테네스의체View: View {
    private let MARGIN: CGFloat = 2
    // 상자 상태
    @State private var boxStates: [[Box]] = []
    @State private var currentPrimeNumbers: [[Int]] = [[0]]
    
    @State private var sceneNumber = 0
    @State private var playButtonText = "play.fill"
    @State private var playButtonTimer: Timer?
    
    // 화면을 그리드형식으로 꽉채워줌
    var columns: [GridItem] {
        return (1...10).map { _ in
            GridItem(.flexible(), spacing: MARGIN)
        }
    }
    
    private var control: some View {
        HStack {
            Stepper("[에라토스테네스의 채] Scene \(sceneNumber)") {
                guard sceneNumber < boxStates.count else {
                    return
                }
                
                sceneNumber += 1
            } onDecrement: {
                guard sceneNumber > 0 else {
                    return
                }
                
                sceneNumber -= 1
            }
            
            Button("", systemImage: playButtonText) {
                guard playButtonText == "play.fill" else {
                    playButtonText = "play.fill"
                    playButtonTimer?.invalidate()
                    return
                }
                
                sceneNumber = 0
                playButtonText = "pause.fill"
                
                playButtonTimer = .scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                    sceneNumber += 1
                    
                    if sceneNumber == totalCount - 2 {
                        timer.invalidate()
                        playButtonText = "play.fill"
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            control
                .padding([.leading, .trailing], 5)
                .padding(.bottom, 2)
            
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Prime numbers")
                        .font(.subheadline)
                        .bold()
                    Text(currentPrimeNumbers[sceneNumber].dropFirst().map(String.init).joined(separator: ", "))
                        .font(.system(size: 9))
                        .frame(height: 40)
                }
            }
            .padding([.leading, .trailing], 5)
            if !boxStates.isEmpty {
                LazyVGrid(columns: columns, spacing: MARGIN) {
                    ForEach(boxStates[sceneNumber].indices, id: \.self) { index in
                        if index != 0 {
                            Rectangle()
                                .fill(boxStates[sceneNumber][index].fillColor ?? .gray)
                                .frame(width: 35, height: 28)
                                .overlay {
                                    Text("\(boxStates[sceneNumber][index].value)")
                                        .font(.system(size: 10, weight: .bold))
                                    
                                }
                        }
                    }
                }
            }
        }
        .onAppear {
            sieveofEratosthenes()
            print(sieveofEratosthenes(200))
        }
    }
}

extension 에라토스테네스의체View {
    
    /*
     algorithm Sieve of Eratosthenes is
         input: an integer n > 1.
         output: all prime numbers from 2 through n.

         let A be an array of Boolean values, indexed by integers 2 to n,
         initially all set to true.
         
         for i = 2, 3, 4, ..., not exceeding √n do
             if A[i] is true
                 for j = i2, i2+i, i2+2i, i2+3i, ..., not exceeding n do
                     set A[j] := false

         return all i such that A[i] is true.
     */
    func sieveofEratosthenes(_ n: Int) -> [Int] {
        var sieve = Array(repeating: true, count: n + 1)
        let rootN = Int(sqrt(Double(n)))
        
        for i in 2...rootN {
            if sieve[i] {
                for j in stride(from: 2 * i, through: n, by: i) {
                    sieve[j] = false
                }
            }
        }
        
        return sieve.enumerated().compactMap { number, isPrime in
            number < 2 ? nil : isPrime ? number : nil
        }
    }
    
    func sieveofEratosthenes() {
        var colors: [Color] = [.red, .green, .blue, .yellow, .purple]
        
        var sieve = Array(repeating: true, count: totalCount + 1)
        let rootN = Int(sqrt(Double(totalCount)))
        
        for i in 2...rootN {
            let fillColor = colors.count > 1 ? colors.removeFirst() : .purple
            if sieve[i] {
                for j in stride(from: 2 * i, through: totalCount, by: i) {
                    sieve[j] = false
                }
            }
            
            if let lastState = boxStates.last {
                let updated = lastState.map {
                    if $0.value % i == 0, $0.fillColor == nil {
                        return Box(value: $0.value, fillColor: fillColor)
                    } else {
                        return $0
                    }
                }
                boxStates.append(updated)
            } else {
                boxStates.append(sieve.enumerated().map {
                    .init(value: $0.offset, fillColor: $0.offset % i == 0 ? .red : nil)
                })
            }
            
            if let lastNumbers = currentPrimeNumbers.last {
                currentPrimeNumbers.append(lastNumbers + (sieve[i] ? [i] : []))
            } else {
                currentPrimeNumbers.append([i])
            }
        }
        
        for i in rootN + 1...totalCount {
            if let lastState = boxStates.last {
                let updated = lastState.map {
                    if $0.value % i == 0, sieve[i], $0.fillColor == nil {
                        return Box(value: $0.value, fillColor: .cyan)
                    } else {
                        return $0
                    }
                }
                
                boxStates.append(updated)
                
                if let lastNumbers = currentPrimeNumbers.last {
                    currentPrimeNumbers.append(lastNumbers + (sieve[i] ? [i] : []))
                }
            }
        }
    }
}

#Preview {
    에라토스테네스의체View()
}
