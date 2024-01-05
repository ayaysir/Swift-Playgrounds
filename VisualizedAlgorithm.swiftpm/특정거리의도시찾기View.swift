//
//  특정거리의도시찾기View.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/02.
//

import SwiftUI

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 화살표 머리, 꼬리의 비율 정하기
        let arrowWidth = rect.width * 0.4
        let arrowHeight = rect.height * 0.6

        // 화살표 꼬리 그리기
        path.move(to: CGPoint(x: rect.midX - arrowWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX + arrowWidth / 2, y: rect.maxY - arrowHeight))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - arrowHeight))

        // 화살표 머리 그리기
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - arrowHeight))
        path.addLine(to: CGPoint(x: rect.midX - arrowWidth / 2, y: rect.maxY - arrowHeight))

        // 패스 닫기
        path.closeSubpath()

        return path
    }
}

struct ArrowSet: View {
    enum Direction {
        case left, right, up, down, diagonal
        
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
            }
        }
    }
    
    var direction: Direction = .up
    @State var isOneOn: Bool = false
    @State var isTwoOn: Bool = false
    
    private var arrow1: some View {
        ArrowShape()
            .fill(isOneOn ? .blue : .gray)
            .frame(width: 30, height: 50)
            .rotationEffect(.degrees(direction.degrees))
    }
    
    private var arrow2: some View {
        ArrowShape()
            .fill(isTwoOn ? .blue : .gray)
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
        case .left, .right, .diagonal:
            VStack(spacing: -20) {
                arrow1
                arrow2
            }
            .frame(width: 100, height: 100)
        }
        
    }
}

struct 특정거리의도시찾기View: View {
    enum CityViewMode {
        case city, road
    }
    
    @ViewBuilder func cityView(cityViewMode: CityViewMode, cityNumber: Int = 0) -> some View {
        switch cityViewMode {
        case .city:
            Rectangle()
                .frame(width: 100, height: 100)
                .overlay {
                    Text("\(cityNumber)")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                }
        case .road:
            Rectangle()
                .fill(.white)
                .frame(width: 100, height: 100)
        }
        
    }
    
    var body: some View {
        VStack {
            HStack {
                cityView(cityViewMode: .city, cityNumber: 1)
                ArrowSet(direction: .right, isOneOn: true, isTwoOn: false)
                cityView(cityViewMode: .city, cityNumber: 2)
            }
            HStack {
                ArrowSet(direction: .down, isOneOn: true, isTwoOn: false)
                ArrowSet(direction: .diagonal, isOneOn: true, isTwoOn: false)
                ArrowSet(direction: .down, isOneOn: true, isTwoOn: false)
            }
            HStack {
                cityView(cityViewMode: .city, cityNumber: 3)
                ArrowSet(direction: .right, isOneOn: true, isTwoOn: false)
                cityView(cityViewMode: .city, cityNumber: 4)
            }
            
        }
    }
}

#Preview {
    특정거리의도시찾기View()
}
