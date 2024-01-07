//
//  ArrowSet.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/07.
//

import SwiftUI

struct ArrowSet: View {
    enum Direction {
        case left, right, up, down, diagonal, diagonalReverse
        
        var degrees: Double {
            return switch self {
            case .left:
                270
            case .right:
                90
            case .up:
                0
            case .down:
                180
            case .diagonal:
                45
            case .diagonalReverse:
                315
            }
        }
    }
    
    var direction: Direction = .up
    @Binding var isOneOn: Bool
    @Binding var isTwoOn: Bool
    
    private var arrow1: some View {
        ArrowShape()
            .fill(isOneOn ? .blue : .clear)
            .frame(width: 30, height: 50)
            .rotationEffect(.degrees(direction.degrees))
    }
    
    private var arrow2: some View {
        ArrowShape()
            .fill(isTwoOn ? .blue : .clear)
            .frame(width: 30, height: 50)
            .rotationEffect(.degrees(direction.degrees + 180))
    }
    
    var body: some View {
        switch direction {
        case .up, .down:
            HStack(spacing: 0) {
                arrow1
                arrow2
            }
            .frame(width: 100, height: 100)
        case .left, .right, .diagonal, .diagonalReverse:
            VStack(spacing: -20) {
                arrow1
                arrow2
            }
            .frame(width: 100, height: 100)
        }
        
    }
}

#Preview {
    ArrowSet(isOneOn: .constant(true), isTwoOn: .constant(true))
}
