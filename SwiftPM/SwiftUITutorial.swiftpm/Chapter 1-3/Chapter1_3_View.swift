//
//  Chapter1_4_View.swift
//  SwiftUITutorial
//
//  Created by 윤범태 on 2023/11/11.
//

import SwiftUI

// Chapter 1-3
struct Chapter1_3_View: View {
    @State var choice: Int = 1
    
    var body: some View {
        VStack {
            Text("Hamlet")
                .font(.largeTitle)
            Text("by William Shakespeare")
                .font(.caption)
                .italic()
            
            Divider()
            
            HStack {
                Image(systemName: "folder.badge.plus")
                Image(systemName: "heart.circle.fill")
                Image(systemName: "alarm")
            }
            .symbolRenderingMode(.multicolor)
            .font(.largeTitle)
            
            Divider()
            
            Label("Favorite Books", systemImage: "books.vertical")
                .labelStyle(.titleAndIcon)
                .font(.largeTitle)
            
            Divider()
            
            HStack {
                Picker("Choice", selection: $choice) {
                    choiceList()
                }
                Button("OK") {
                    applyChanges()
                }
            }
            .controlSize(.mini)
            
            HStack {
                Picker("Choice", selection: $choice) {
                    choiceList()
                }
                Button("OK") {
                    applyChanges()
                }
            }
            .controlSize(.large)
        }
        
        Image("Yellow_Daisy")
            .resizable()
            .scaledToFit()
        
        HStack {
            Rectangle()
                .foregroundStyle(.blue)
            Circle()
                .foregroundStyle(.orange)
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .foregroundStyle(.green)
        }
        .aspectRatio(3.0, contentMode: .fit)
    }
    
    @ViewBuilder func choiceList() -> some View {
        Text("1").tag(1)
        Text("2").tag(2)
        Text("3").tag(3)
    }
    
    func applyChanges() {
        
    }
}

#Preview {
    Chapter1_3_View()
}
