//
//  MIDIFilePlayConductor.swift
//  MIDIFilePlay
//
//  Created by 윤범태 on 2/2/24.
//

import AVFAudio

class MIDIFilePlayConductor: ObservableObject {
    var midiPlayer: AVMIDIPlayer?
    var soundfontURL: URL? = Bundle.main.url(forResource: "CT8MGM", withExtension: "sf2")
    
    @Published var currentPosition: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool = false
    
    init() {
        guard let soundfontURL else {
            return
        }
        
        guard let sampleMIDIFile = Bundle.main.url(forResource: "Human1", withExtension: "mid") else {
            return
        }
        
        do {
            midiPlayer = try AVMIDIPlayer(contentsOf: sampleMIDIFile, soundBankURL: soundfontURL)
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self else {
                    return
                }
                
                currentPosition = midiPlayer?.currentPosition ?? 0
                duration = midiPlayer?.duration ?? 0
                isPlaying = midiPlayer?.isPlaying ?? false
            }
        } catch {
            print(error)
        }
    }
    
    func play() {
        DispatchQueue.global().async {
            self.midiPlayer?.play {
                print("Music play completed.")
                self.midiPlayer?.currentPosition = 0
            }
        }
    }
    
    func stop() {
        DispatchQueue.global().async {
            self.midiPlayer?.stop()
        }
    }
    
    func changePosition(_ position: Double) {
        midiPlayer?.currentPosition = position
        currentPosition = position
    }
}
