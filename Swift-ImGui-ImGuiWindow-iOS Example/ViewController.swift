//
//  ViewController.swift
//  Swift-ImGui-ImGuiWindow-iOS Example
//
//  Created by Hiroaki Yamane on 8/1/18.
//  Copyright © 2018 Hiroaki Yamane. All rights reserved.
//

import UIKit
import ImGui

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v = UIView(frame: CGRect(origin: view.center, size: CGSize(width: 50, height: 50)))
        v.center = view.center
        v.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        view.addSubview(v)
        
        ImGui.draw { (imgui) in
            struct Temp {
                static var duration: CGFloat = 1.0
                static var dampingRatio: CGFloat = 0.86
            }
            
            imgui.setWindowFontScale(2.0)
            imgui.sliderFloat("Duration", v: &Temp.duration, minV: 0.01, maxV: 3.0)
            imgui.sliderFloat("Damping Ratio", v: &Temp.dampingRatio, minV: 0.01, maxV: 2.0)
            if imgui.button("animate") {
                DispatchQueue.main.async {
                    let center = v.center
                    let propAnimator = UIViewPropertyAnimator(duration: TimeInterval(Temp.duration), dampingRatio: Temp.dampingRatio, animations: {
                        v.center = CGPoint(x: center.x, y: center.y - 100.0)
                    })
                    propAnimator.addCompletion({ (p) in
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                            v.center = center
                        })
                    })
                    propAnimator.startAnimation()
                }
            }
        }
    }
}

