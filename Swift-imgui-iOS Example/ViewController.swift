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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .red
        
        ImGui.initialize(.metal)
        
        if let vc = ImGui.vc {
            addChildViewController(vc)
            view.addSubview(vc.view)
            vc.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.5)
        }
        
        ImGui.draw { (imgui) in
            
            imgui.begin(name: "Hello Metal")
            
            if imgui.button(label: "what") {
                Swift.print("What")
            }
//            imgui.colorEdit(label: "Background Color", color: &self.imguiVC.backgroundColor)
            var size = self.view.frame.size
            imgui.sliderFloat2(label: "size", v: &size, minV: 0.0, maxV: 500.0)
            self.view.frame.size = size
            imgui.end()
            
        }
       
    }
    
}
