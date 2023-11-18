//
//  MeetingViewII.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import SwiftUI
import AVFoundation

struct MeetingView2: View {
    @Binding var scrum: DailyScrum
    @StateObject var scrumTimer = ScrumTimer()
    
    private var player: AVPlayer {
        AVPlayer.sharedDingPlayer
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(scrum.theme.mainColor)
            VStack {
                MeetingHeaderView(secondsElapsed: scrumTimer.secondsElapsed,
                                  secondsRemaining: scrumTimer.secondsRemaining,
                                  theme: scrum.theme)
                // ProgressView(value: 10, total: 15)
                // HStack {
                //     VStack(alignment: .leading) {
                //         Text("Seconds Elapsed")
                //             .font(.caption)
                //         Label("300", systemImage: "hourglass.tophalf.fill")
                //     }
                //     Spacer()
                //     VStack(alignment: .leading) {
                //         Text("Seconds Remaining")
                //             .font(.caption)
                //         Label("600", systemImage: "hourglass.bottomhalf.fill")
                //             .labelStyle(.trailingIcon)
                //     }
                // }
                
                /*
                 Ignore the inferred accessibility labels and values for the child views of the HStack in the header.

                 Adding supplemental data in the next few steps improves the accessibility experience.
                 */
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Time remaining")
                .accessibilityValue("10 minutes")
                Circle()
                    .strokeBorder(lineWidth: 24)
                MeetingFooterView(speakers: scrumTimer.speakers, skipAction: scrumTimer.skipSpeaker)
                // HStack {
                //     Text("Speaker 1 of 3")
                //     Spacer()
                //     Button(action: {}) {
                //         Image(systemName: "forward.fill")
                //     }
                //     .accessibilityLabel("Next speaker")
                // }
            }
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
        .onAppear {
            startScrum()
        }
        .onDisappear {
            endScrum()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension MeetingView2 {
    private func startScrum() {
        scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
        scrumTimer.speakerChangedAction = {
            player.seek(to: .zero)
            player.play()
        }
        scrumTimer.startScrum()
    }
    
    private func endScrum() {
        scrumTimer.stopScrum()
        let newHistory = History(attendees: scrum.attendees)
        scrum.history.insert(newHistory, at: 0)
    }
}

#Preview {
    MeetingView2(scrum: .constant(DailyScrum.sampleData[0]))
}
