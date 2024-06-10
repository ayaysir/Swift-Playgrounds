//
//  MeetingView.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI

struct MeetingView: View {
    @StateObject var scrumTimer = ScrumTimerExample()
    
    var body: some View {
        VStack {
            ProgressView(value: 10, total: 15)
            HStack {
                VStack(alignment: .leading) {
                    Text("Seconds Elapsed")
                        .font(.caption)
                    Label("300", systemImage: "hourglass.tophalf.fill")
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Seconds Remaining")
                        .font(.caption)
                    Label("600", systemImage: "hourglass.bottomhalf.fill")
                }
            }
            /*
             Ignore the inferred accessibility labels and values for the child views of the HStack in the header.

             Adding supplemental data in the next few steps improves the accessibility experience.
             */
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Time remaining")
            .accessibilityValue("10 minutes")
            Circle()
                .strokeBorder(lineWidth: 24)
            HStack {
                Text("Speaker 1 of 3")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "forward.fill")
                }
                .accessibilityLabel("Next speaker")
            }
        }
        .padding()
    }
}

#Preview {
    MeetingView()
}
