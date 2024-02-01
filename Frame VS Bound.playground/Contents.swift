//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView() // superview
        view.backgroundColor = .black
        view.frame.size = .init(width: 400, height: 700)
        self.view = view
        
        // label
        let superviewLabel = UILabel(frame: .init(x: 250, y: 0, width: 300, height: 50))
        superviewLabel.text = "Super View"
        superviewLabel.textColor = .white
        superviewLabel.font = .systemFont(ofSize: 20, weight: .bold)
        view.addSubview(superviewLabel)

        let subview1 = UIImageView()
        subview1.backgroundColor = .yellow
        subview1.frame = .init(x: 0, y: 0, width: 200, height: 400)
        
        subview1.contentMode = .center
        
        view.addSubview(subview1)
        
        let label = UILabel(frame: .init(x: 10, y: 630, width: 500, height: 50))
        label.text = "subview1 frame origin: \(subview1.frame.origin)"
        label.textColor = .white
        view.addSubview(label)
        
        // (1) Frame 애니메이션
        // moveFrame(subview1, descriptionLabel: label)
        
        let grandChildView = UIView()
        grandChildView.backgroundColor = .red
        grandChildView.frame = .init(x: 50, y: 100, width: 30, height: 30)
        subview1.addSubview(grandChildView)
        
        // (3) subview 변형 후 frame, bounds 비교
        subview1.transform = .init(rotationAngle: 80)
        
        print(view.frame, view.bounds)
        print(subview1.frame, subview1.bounds)
        
        // (2) Bounds 애니메이션
        subview1.frame.origin = .init(x: 100, y: 100)
        moveBounds(subview1, descriptionLabel: label)
        
        /*
         (0.0, 0.0, 400.0, 700.0) (0.0, 0.0, 400.0, 700.0)
         (100.0, 56.92118766077988, 419.6329103371596, 329.0902529987343) (0.0, 0.0, 287.7701033516019, 390.25172511809495)
         */
    }
}

class FrameBoundSizeViewController: UIViewController {
    override func loadView() {
        let view = UIView() // superview
        view.backgroundColor = .black
        view.frame.size = .init(width: 500, height: 500)
        self.view = view
        
        let subview1 = UIImageView()
        subview1.backgroundColor = .yellow
        subview1.frame = .init(x: 200, y: 200, width: 200, height: 300)
        view.addSubview(subview1)
        
        // (1) frame만 설정한 상태에서 bounds 사이즈는?
        print(subview1.frame, subview1.bounds)
        // (100.0, 100.0, 200.0, 300.0) (0.0, 0.0, 200.0, 300.0)
        
        // (2) bounds 사이즈를 변경하면 frame은 어떻게?
        subview1.bounds.size = .init(width: 300, height: 400)
        subview1.bounds.origin = .init(x: 0, y: 0)
        
        print(subview1.frame, subview1.bounds)
        // (50.0, 50.0, 300.0, 400.0) (0.0, 0.0, 300.0, 400.0)
        
        let grandChildView2 = UIView()
        grandChildView2.backgroundColor = .magenta
        grandChildView2.frame = .init(x: 0, y: 0, width: 200, height: 150)
        subview1.addSubview(grandChildView2)
        
        let grandChildView = UIView()
        grandChildView.backgroundColor = .cyan
        grandChildView.frame = .init(x: 0, y: 0, width: 200, height: 150)
        subview1.addSubview(grandChildView)
        grandChildView.transform = .init(rotationAngle: 50)
        print(grandChildView.frame, grandChildView.bounds)
        
        // grandChildView.layer.compositingFilter = "multiplyBlendMode"
        
        // for i in 0...3 {
        //     let gcView = UIView()
        //     gcView.backgroundColor = .systemPink
        //     gcView.frame = .init(x: i * 30, y:  i * 30, width: 5, height: 5)
        //     subview1.addSubview(gcView)
        // }
    }
}

// Present the view controller in the Live View window
// PlaygroundPage.current.liveView = MyViewController()
PlaygroundPage.current.liveView = FrameBoundSizeViewController()

func moveFrame(_ view: UIView, descriptionLabel label: UILabel) {
    var count = 0
    Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
        guard count < 100 else {
            timer.invalidate()
            return
        }
        
        view.frame.origin = .init(x: view.frame.origin.x + 1, y: view.frame.origin.y + 1)
        label.text = "subview frame origin: \(view.frame.origin)"
        count += 1
    }
}

func moveBounds(_ view: UIView, descriptionLabel label: UILabel) {
    var count = 0
    Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { timer in
        guard count < 100 else {
            timer.invalidate()
            return
        }
        
        let afterX = min(50, view.bounds.origin.x + 1)
        let afterY = min(100, view.bounds.origin.y + 1)
        
        view.bounds.origin = .init(x: afterX, y: afterY)
        label.text = "subview bounds origin: \(view.bounds.origin)"
        count += 1
    }
}


