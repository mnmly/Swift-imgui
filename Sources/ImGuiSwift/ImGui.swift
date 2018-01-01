//
//  ImGui.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 5/13/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import SceneKit

public class ImGui {
    
    public enum API {
        case metal
        case opengl
    }
    
    public static var hidden = false {
        didSet {
            if let vc = vc as? ImGuiSceneViewController { vc.hidden = hidden }
        }
    }
    
    public static var vc: ViewControllerAlias?
    public class func initialize(_ api: API = .opengl, fontPath: String? = nil) {
        switch api {
        case .metal:
            vc = ImGuiMTKViewController(fontPath: fontPath)
            if let vc = vc as? ImGuiMTKViewController {
                if !vc.isAvailable {
                    print("Metal API is not available, falling back to OpenGL API.")
                    initialize(.opengl, fontPath: fontPath)
                }
            }
        break
        case .opengl:
            #if os(iOS)
            vc = ImGuiGLKViewController(fontPath: fontPath)
            #endif
        break
        }
    }
    
    public class func initialize(sceneView: SCNView, fontPath: String? = nil) {
        vc = ImGuiSceneViewController()
        if let _vc = vc as? ImGuiSceneViewController {
            _vc.fontPath = fontPath
            _vc.sceneView = sceneView
        }
    }
    
    public class func reset() {
        if var vc = vc as? ImGuiViewControllerProtocol {
            vc.drawBlocks.removeAll()
        }
    }
    
    public class func draw(_ block: @escaping ImGuiDrawCallback) {
        if var vc = vc as? ImGuiViewControllerProtocol {
            vc.drawBlocks.append(block)
        }
    }
}

