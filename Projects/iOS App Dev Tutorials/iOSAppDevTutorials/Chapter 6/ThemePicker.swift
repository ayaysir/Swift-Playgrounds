//
//  ThemePicker.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

struct ThemePicker: View {
    @Binding var selection: Theme
    
    var body: some View {
        Picker("Theme", selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ThemeView(theme: theme)
                    .tag(theme)
            }
        }
        .pickerStyle(.navigationLink)
    }
}

#Preview {
    ThemePicker(selection: .constant(.periwinkle))
}
