//
//  ImGuiSceneViewController.swift
//  Swift-ImGui-iOS
//
//  Created by Hiroaki Yamane on 1/1/18.
//  Copyright © 2018 Hiroaki Yamane. All rights reserved.
//

import SceneKit

public class ImGuiSceneViewController: ViewControllerAlias, ImGuiViewControllerProtocol {
    
    public var hidden = false
    public var drawBlocks: [ImGuiDrawCallback] = []
    public var fontPath: String?
    private var size = CGSize.zero
    public var imguiMetal: ImGuiMetal!
    public var sceneView: SCNView? {
        didSet {
            sceneView!.delegate = self
            imguiMetal = ImGuiMetal(device: sceneView!.device!, fontPath: fontPath)
            imguiMetal.setupGestures(view: sceneView!)
            imguiMetal.setViewport(size: view.frame.size, scale: UIScreen.main.scale)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imguiMetal.setViewport(size: sceneView!.frame.size, scale: UIScreen.main.scale)
    }
}

extension ImGuiSceneViewController: SCNSceneRendererDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if !hidden {
            
            if let commandEncoder = self.sceneView?.currentRenderCommandEncoder {
                
                imguiMetal.pixelFormat = renderer.colorPixelFormat
                imguiMetal.depthPixelFormat = renderer.depthPixelFormat
                
                imguiMetal.newFrame(commandEncoder: commandEncoder)
                
                drawBlocks.forEach({ (block) in
                    block(self.imguiMetal)
                })
                
                //            objc_sync_enter(self)
                imguiMetal.render()
                
                //            objc_sync_exit(self)
            }
        }
    }
}

