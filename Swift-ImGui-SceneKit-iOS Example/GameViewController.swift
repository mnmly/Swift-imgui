//
//  GameViewController.swift
//  Swift-ImGui-SceneKit-iOS Example
//
//  Created by Hiroaki Yamane on 12/26/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Metal
import ImGui

class GameViewController: UIViewController {

    var renderSemaphore = DispatchSemaphore(value: 6)
    var imguiMetal: ImGuiMetal!
    var size = CGSize.zero
    var sceneView: SCNView!
    var ship: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        scene.background.contents = UIColor.white

        // retrieve the ship node

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        sceneView = scnView
        
        // animate the 3d object
        ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        sceneView.isPlaying = true
        sceneView.loops = true
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
//        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        scnView.delegate = self
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        size = view.frame.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let device = sceneView.device {
            imguiMetal = ImGuiMetal(device: device, fontPath: Bundle.main.path(forResource: "SFMono-Regular", ofType: "ttf"))
            imguiMetal.setupGestures(view: sceneView)
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer? = nil) {
        // retrieve the SCNView
        
            // get its material
            let material = ship.childNodes.first!.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}

extension GameViewController: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if let commandEncoder = self.sceneView.currentRenderCommandEncoder {
            
            let scale = UIScreen.main.scale
            
            imguiMetal.pixelFormat = renderer.colorPixelFormat
            imguiMetal.depthPixelFormat = renderer.depthPixelFormat
            
            imguiMetal.setViewport(size: size, scale: scale)
        
            imguiMetal.newFrame(commandEncoder: commandEncoder)
            
            imguiMetal.setNextWindowSize(CGSize(width: 300, height: 200))
            imguiMetal.begin("SceneKit Demo")
            imguiMetal.setWindowFontScale(2.0)

            if imguiMetal.button("Tap to tint the ship to red") {
                DispatchQueue.main.async {
                    self.handleTap()
                }
            }
            imguiMetal.end()
//            objc_sync_enter(self)
            imguiMetal.render()

//            objc_sync_exit(self)
            }
        }
}
