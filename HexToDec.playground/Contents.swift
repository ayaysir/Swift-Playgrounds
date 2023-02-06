/**
 int midiDecTime2normalTime(int[] n) {
   int l=n.length;    int t=0;
   for (int i=0 ; i<l-1 ; i++) {
     t += (n[i]-128) * Math.pow(2,7 * (l-i-1)) ;
   }
   t += n[l-1];
   return t;
 }
 */

import Foundation

func midiDecTimeToNormalTime(n: [Int]) -> Int {
    let l = n.count
    var t = 0
    
    for i in 0 ..< l - 1 {
//        print(NSDecimalNumber(decimal: pow(2, 7 * (l - i - 1))).intValue)
        l - i - 1
        let post = NSDecimalNumber(decimal: pow(2, 7 * (l - i - 1))).intValue
        t += (n[i] - 128) * post
    }
    t += n[l-1]
    return t
}

midiDecTimeToNormalTime(n: [135, 135, 135])




protocol KeyboardDelegate: AnyObject {
    func didPressedSpace(_ keyboard: Keyboard)
}

class Keyboard {
    weak var delegate: KeyboardDelegate?
    
    func pressSpace() {
        delegate?.didPressedSpace(self)
    }
}

class TetrisGame: KeyboardDelegate {
    
    let keyboard = Keyboard()
    
    init() {
        keyboard.delegate = self
    }
    
    func didPressedSpace(_ keyboard: Keyboard) {
        print("누르면 테트리스 블록이 즉시 낙하한다.")
    }
}

class ShootingGame: KeyboardDelegate {
    
    let keyboard = Keyboard()
    
    init() {
        keyboard.delegate = self
    }
    
    func didPressedSpace(_ keyboard: Keyboard) {
        print("누르면 비행기에서 미사일이 발사된다.")
    }
}

let tetris = TetrisGame()
tetris.keyboard.pressSpace()

let shooting = ShootingGame()
shooting.keyboard.pressSpace()

class Keyboard1 {
    
    let app: String!
    
    init(app: String) {
        self.app = app
    }
    
    func pressSpace() {
        switch app {
        case "tetris":
            print("누르면 테트리스 블록이 즉시 낙하한다.")
        case "shooting game":
            print("누르면 비행기에서 미사일이 발사된다.")
        case "word":
            print("누르면 한 칸 띄운다.")
        default:
            print("기타 등등...")
        }
    }
}

class TetrisGame1 {
    let keyboard = Keyboard1(app: "tetris")
}

let tetris1 = TetrisGame1()
tetris1.keyboard.pressSpace()
