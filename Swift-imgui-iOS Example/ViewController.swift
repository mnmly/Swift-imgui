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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        myView.backgroundColor = UIColor(hue:0.592, saturation:0.904, brightness:0.980, alpha:1.000)
        
        myView.center = view.center
        
        view.addSubview(myView)
        
        ImGui.initialize(.metal)
        
        if let vc = ImGui.vc {
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: view.frame.height * 0.7, width: view.frame.width, height: view.frame.height * 0.3)
        }
        
        ImGui.draw { (imgui) in
            
            imgui.setNextWindowPos(CGPoint.zero, cond: .always)
            imgui.setNextWindowSize(self.view.frame.size)
            imgui.begin("Hello ImGui on Swift")
            imgui.setWindowFontScale(UIScreen.main.scale)
            
            var center = self.view.center
            
            center.x += self.viewOffset.x
            center.y += self.viewOffset.y
            
            self.myView.center = center
            
            if imgui.button("rotate me") {
                self.myView.transform = CGAffineTransform.identity
                UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.9, animations: {
                    self.myView.transform = CGAffineTransform.init(rotationAngle: 180.0)
                }).startAnimation()
            }
            
            imgui.sliderFloat2("offset", v: &self.viewOffset, minV: -100.0, maxV: 100.0)
            imgui.sliderFloat2("size", v: &self.myView.bounds.size, minV: 5.0, maxV: 100.0)
            imgui.sliderFloat("cornerRadius", v: &self.myView.layer.cornerRadius, minV: 0.0, maxV: 10.0)
            imgui.colorEdit("backgroundColor", color: &(self.myView.backgroundColor)!)
            imgui.end()
            
        }
       
    }
    
}
