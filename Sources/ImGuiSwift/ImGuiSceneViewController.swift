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
    weak var previousDelegate: SCNSceneRendererDelegate?
    
    public var sceneView: SCNView? {
        didSet {
            previousDelegate  = sceneView?.delegate
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
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        previousDelegate?.renderer?(renderer, updateAtTime: time)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        previousDelegate?.renderer?(renderer, didApplyAnimationsAtTime: time)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        previousDelegate?.renderer?(renderer, didSimulatePhysicsAtTime: time)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
        if #available(iOS 11.0, macOS 10.13, *) {
            previousDelegate?.renderer?(renderer, didApplyConstraintsAtTime: time)
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        previousDelegate?.renderer?(renderer, willRenderScene: scene, atTime: time)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        previousDelegate?.renderer?(renderer, didRenderScene: scene, atTime: time)
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
