//
//  QuickDemoViewControllerMac.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import UIKit
import ImGui

class ViewController: UIViewController {
    
    var myView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    var viewOffset: CGPoint = CGPoint.zero
    var points: [CGPoint] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        myView.backgroundColor = UIColor(hue:0.592, saturation:0.904, brightness:0.980, alpha:1.000)
        myView.layer.allowsEdgeAntialiasing = true
        myView.center = view.center
        view.addSubview(myView)
        
        for i in 0 ..< 180 {
            points.append(CGPoint(x: Double(i), y: sin(Double(i) / 180.0)))
        }
        
        
        ImGui.initialize(.metal, fontPath: Bundle.main.path(forResource: "SFMono-Regular", ofType: "ttf"))
        
        if let vc = ImGui.vc {
            addChild(vc)
            view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: view.frame.height * 0.7, width: view.frame.width, height: view.frame.height * 0.3)
        }
        
        
        ImGui.draw { (imgui) in
            
            imgui.setNextWindowPos(CGPoint.zero, cond: .always)
            imgui.setNextWindowSize(self.view.frame.size)
            imgui.pushStyleVar(.windowRounding, value: 0.0)
            imgui.pushStyleColor(ImGuiColor.border, color: UIColor.red)
            
            imgui.begin("Hello ImGui on Swift")
            
            var center = self.view.center
            center.x += self.viewOffset.x
            center.y += self.viewOffset.y
            
            self.myView.center = center
            
            if imgui.button("rotate me") {
                DispatchQueue.main.async {
                    UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.9, animations: {
                        self.myView.transform = self.myView.transform.rotated(by: 540.0 * .pi / 180.0)
                    }).startAnimation()
                }
            }
            
            self.points.removeAll()
            
            let time = Double(imgui.getTime())
            
            for i in 0 ..< 180 {
                self.points.append(CGPoint(x: Double(i), y: sin(Double(i) + time * 10.0)))
            }
            
            imgui.sliderFloat2("offset", v: &self.viewOffset, minV: -100.0, maxV: 100.0)
            imgui.sliderFloat2("size", v: &self.myView.bounds.size, minV: 5.0, maxV: 100.0)
            imgui.sliderFloat("cornerRadius", v: &self.myView.layer.cornerRadius, minV: 0.0, maxV: 10.0)

            imgui.colorEdit("backgroundColor", color: &self.myView.backgroundColor)
            
            struct Temp {
                static var c: UIColor = UIColor.white
            }
            
            imgui.colorEdit("backgroundColor 2", color: &Temp.c)
            
            let posY = (self.points.map({ (p) -> CGFloat in
                return p.y
            }))
            
            imgui.plotLines("Sine", values: posY, valuesOffset: 0, overlayText: "", scaleMin: -1.0, scaleMax: 1.0)
            
            imgui.end()
            imgui.popStyleColor()
            imgui.popStyleVar()
        }
       
    }
    
}
