//
//  FavoriteButton.swift
//  SwiftUITutorial-Chapter123
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

// 3: Handling user input
struct FavoriteButton: View {
    @Binding var isSet: Bool

    var body: some View {
        Button {
            isSet.toggle()
        } label: {
            Label("Toggle Favorite", systemImage: isSet ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundStyle(isSet ? .yellow : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isSet: .constant(true))
}
