import UIKit

var greeting = "Hello, playground"

import Foundation

enum Scale: Int, CaseIterable, Codable {
    case C, C_sharp, D, D_sharp, E, F, F_sharp, G, G_sharp, A, A_sharp, B
    
    var textValueForSharp: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "C#"
        case .D: return "D"
        case .D_sharp: return "D♯"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "F♯"
        case .G: return "G"
        case .G_sharp: return "G♯"
        case .A: return "A"
        case .A_sharp: return "A♯"
        case .B: return "B"
        }
    }
    
    var textValueForFlat: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "D♭"
        case .D: return "D"
        case .D_sharp: return "E♭"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "G♭"
        case .G: return "G"
        case .G_sharp: return "A♭"
        case .A: return "A"
        case .A_sharp: return "B♭"
        case .B: return "B"
        }
    }
    
    var textValueMixed: String {
        switch self {
        case .C: return "C"
        case .C_sharp: return "C# / D♭"
        case .D: return "D"
        case .D_sharp: return "D♯ / E♭"
        case .E: return "E"
        case .F: return "F"
        case .F_sharp: return "F♯ / G♭"
        case .G: return "G"
        case .G_sharp: return "G♯ / A♭"
        case .A: return "A"
        case .A_sharp: return "A♯ / B♭"
        case .B: return "B"
        }
    }
    
    
    
    var justIntonationRatio: [Float] {
        switch self {
        case .C: return [1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8]
        case .C_sharp: return [15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5]
        case .D: return [9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3]
        case .D_sharp: return [5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5]
        case .E: return [8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2]
        case .F: return [3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32]
        case .F_sharp: return [45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4, 4/3]
        case .G: return [4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5, 5/4]
        case .G_sharp: return [5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8, 6/5]
        case .A: return [6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, 25/24, 9/8]
        case .A_sharp: return [9/8/2, 6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1, (25/24)]
        case .B: return [25/24/2, 9/8/2, 6/5/2, 5/4/2, 4/3/2, 45/32/2, 3/2/2, 8/5/2, 5/3/2, 9/5/2, 15/8/2, 1]
        }
    }
}

let NOTE_NAMES = ["C", "C♯ / D♭", "D", "D♯ / E♭", "E", "F", "F♯ / G♭", "G", "G♯ / A♭", "A", "A♯ / B♭", "B"]
let ALT_NOTE_NAMES: [String: String] = [
    "C♯": "D♭",
    "D♯": "E♭",
    "F♯": "G♭",
    "G♯": "A♭",
    "A♯": "B♭"
]
let BASE_NOTE = "A"
let BASE_OCTAVE = 4
let SPEED_OF_SOUND = 34500
let EXP = pow(2, (1 / 12) as Float)
let OCTAVE_START = 1
let OCTAVE_END = 7

let JUST_RATIO_MAJOR: [Float] = [1, 25/24, 9/8, 6/5, 5/4, 4/3, 45/32, 3/2, 8/5, 5/3, 9/5, 15/8]


    let indexOfA = NOTE_NAMES.firstIndex {$0 == "A"}!
indexOfA
    let distanceFromBaseToLowest = NOTE_NAMES.count * (BASE_OCTAVE - OCTAVE_START) + indexOfA
    var distIndex = 0
    
    // A4로부터 A1 계산하기
    // 4     3  2  1
    // 440  /2 /2 /2 = 55
    // A4를 비율을 나누기로 하면 C1이 나옴?

let powered = pow(2, BASE_OCTAVE - OCTAVE_START)
let c4FreqJI = 436.05 / JUST_RATIO_MAJOR[indexOfA]
let cLowestOctaveFreq: Float = c4FreqJI / Float(truncating: powered as NSNumber)

var rootFreq = cLowestOctaveFreq
for octave in 1...7 {
    for (index, note) in NOTE_NAMES.enumerated() {
        let a = rootFreq * JUST_RATIO_MAJOR[index]
        print(note, octave, a, index)
        // 2배가 되었을 때
        if index >= NOTE_NAMES.count - 1 {
            rootFreq *= 2
            print("aaa:", rootFreq)
        }
    }
}
 
let semitone = 69

func getNote(frequency: Float) -> Float {
    let note = 12 * (log(frequency / 440) / log(2))
    return roundf(note) + Float(semitone)
}

func getStandardFrequency(noteNum: Float) -> Float {
    let exponent = (noteNum - Float(semitone)) / 12
    return 440 * Float(truncating: pow(2, exponent) as NSNumber)
}

func getCents(frequency: Float, noteNum: Float) -> Float {
    return floor((1200 * log(frequency / getStandardFrequency(noteNum: noteNum))) / log(2.0))
}

let freq: Float = 454.0005
let noteNum = getNote(frequency: freq)
let sf = getStandardFrequency(noteNum: noteNum)
getCents(frequency: freq, noteNum: noteNum)

func getA4Frequency_ET(baseNote4: Scale, frequency: Float) -> Float {
    var distFromA4: Int {
        return baseNote4.rawValue <= Scale.A.rawValue
            ? Scale.A.rawValue - baseNote4.rawValue
            : (baseNote4.rawValue - Scale.A.rawValue) * -1
    }
    return frequency * pow(EXP, Float(distFromA4))
    
}
getA4Frequency_ET(baseNote4: Scale.B, frequency: 493.88)


