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
    
    var myView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.addSubview(myView)
        
        ImGui.initialize(.metal)
        
        if let vc = ImGui.vc {
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5)
        }
        
        ImGui.draw { (imgui) in
            
            imgui.setNextWindowPos(CGPoint.zero, cond: .always)
            imgui.setNextWindowSize(self.view.frame.size)
            imgui.begin("Hello Metal")
            imgui.setWindowFontScale(UIScreen.main.scale)
            if imgui.button("what") {
                Swift.print("What")
            }
//            imgui.colorEdit(label: "Background Color", color: &self.imguiVC.backgroundColor)
            var size = self.view.frame.size
            imgui.sliderFloat2("size", v: &size, minV: 0.0, maxV: 500.0)
            self.view.frame.size = size
            imgui.end()
            
        }
       
    }
    
}
