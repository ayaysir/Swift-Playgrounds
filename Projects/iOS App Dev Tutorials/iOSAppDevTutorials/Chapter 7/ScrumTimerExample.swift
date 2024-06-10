//
//  ScrumTimer.swift
//  iOSAppDevTutorials
//
//  Created by 윤범태 on 2023/11/18.
//

import Foundation

class ScrumTimerExample: ObservableObject {
   @Published var activeSpeaker = ""
   @Published var secondsElapsed = 0
   @Published var secondsRemaining = 0
   // ...
}
