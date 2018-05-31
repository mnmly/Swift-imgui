//
//  ImGuiSceneViewController.swift
//  Swift-ImGui-iOS
//
//  Created by Hiroaki Yamane on 1/1/18.
//  Copyright © 2018 Hiroaki Yamane. All rights reserved.
//

import SceneKit
#if os(OSX)
import Cocoa
#else
import UIKit
#endif


public class ImGuiSceneViewController: ViewControllerAlias, ImGuiViewControllerProtocol {
    
    public var hidden = false
    public var drawBlocks: [ImGuiDrawCallback] = []
    public var fontPath: String?
    private var size = CGSize.zero
    public var imgui: ImGuiBase!
    public var sceneView: SCNView? {
        didSet {
            sceneView!.delegate = self
            #if targetEnvironment(simulator)
            #else
            imgui = ImGuiMetal(view: sceneView!, fontPath: fontPath)
            #endif
            imgui.setupGestures(view: sceneView!)
            #if os(iOS)
            imgui.setViewport(size: view.frame.size, scale: UIScreen.main.scale)
            #endif
        }
    }
    
    #if os(iOS)
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imgui.setViewport(size: sceneView!.frame.size, scale: UIScreen.main.scale)
    }
    #endif
}

extension ImGuiSceneViewController: SCNSceneRendererDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if !hidden {
            #if targetEnvironment(simulator)
            #else
            if let commandEncoder = self.sceneView?.currentRenderCommandEncoder {
                if let imguiMetal = imgui as? ImGuiMetal {
                    imguiMetal.pixelFormat = renderer.colorPixelFormat
                    imguiMetal.depthPixelFormat = renderer.depthPixelFormat
                    
                    imguiMetal.newFrame(commandEncoder: commandEncoder)
                    
                  
                }
                
                drawBlocks.forEach({ (block) in
                    block(self.imgui)
                })
                
                //            objc_sync_enter(self)
                imgui.render()
                
                //            objc_sync_exit(self)
            }
            #endif
        }
    }
}
