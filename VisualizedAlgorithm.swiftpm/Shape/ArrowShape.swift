//
//  ArrowShape.swift
//  VisualizedAlgorithm
//
//  Created by 윤범태 on 2024/01/07.
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

#Preview {
    ArrowShape()
}
