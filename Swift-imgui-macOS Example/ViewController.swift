//
//  ViewController.swift
//  Swift-imgui-macOS Example
//
//  Created by Hiroaki Yamane on 5/13/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import Cocoa
import ImGui

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImGui.initialize(.metal)
        if let vc = ImGui.vc {
            addChildViewController(vc)
            vc.view.layer?.backgroundColor = NSColor.clear.cgColor
            vc.view.frame = view.frame
            view.addSubview(vc.view)
        }
        
        ImGui.draw { (imgui) in
            imgui.pushStyleVar(ImGuiStyleVar.windowRounding, value: 0.0)
            imgui.begin("Hello ImGui")
            if imgui.button("Click me") {
                Swift.print("you clicked me.")
            }
            imgui.end()
            imgui.popStyleVar()
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

