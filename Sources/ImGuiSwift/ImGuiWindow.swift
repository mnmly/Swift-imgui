//
//  ImGuiWindow.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

import UIKit
import SceneKit

@objc public final class ImGuiWindow: UIWindow {
	
	public enum GestureType {
		case shake
		case gesture(UIGestureRecognizer)
	}
    
    public var frameOverride: CGRect?
    public var sceneView: SCNView? {
        didSet {
            ImGui.initialize(sceneView: sceneView!, fontPath: fontPath)
        }
    }
	
	/// The amount of time you need to shake your device to bring up the ImGui UI
	private static let shakeWindowTimeInterval: Double = 0.4
	
	/// The GestureType used to determine when to present the UI.
	private let gestureType: GestureType
	
	/// By holding on to the ImGuiViewController, we get easy state restoration!
	public var imguiViewController: ViewControllerAlias! // requires self for init
	
	/// Whether or not the device is shaking. Used in determining when to present the ImGui UI when the device is shaken.
	private var shaking: Bool = false
	
	private var shouldPresentImGui: Bool {
		switch gestureType {
		case .shake: return shaking
		case .gesture: return true
		}
	}
    
    private var fontPath: String?
	
	// MARK: Init
	
    public init(frame: CGRect, api: ImGui.API = .metal, fontPath: String? = nil, gestureType: GestureType = .shake) {
		self.gestureType = gestureType
		
//		// Are we running on a Mac? If so, then we're in a simulator!
//		#if (arch(i386) || arch(x86_64))
//			self.runningInSimulator = true
//		#else
//			self.runningInSimulator = false
//		#endif
		
		super.init(frame: frame)
        
        self.fontPath = fontPath
		
		// tintColor = AppTheme.Colors.controlTinted
		
		switch gestureType {
		case .gesture(let gestureRecognizer):
			gestureRecognizer.addTarget(self, action: #selector(self.presentImGui))
		case .shake:
			break
		}
        
        ImGui.initialize(api, fontPath: fontPath)
        
        if let vc = ImGui.vc {
            imguiViewController = vc
        }
	}
    
    public init(frame: CGRect, fontPath: String? = nil, gestureType: GestureType = .shake) {
        self.gestureType = gestureType
        
        //        // Are we running on a Mac? If so, then we're in a simulator!
        //        #if (arch(i386) || arch(x86_64))
        //            self.runningInSimulator = true
        //        #else
        //            self.runningInSimulator = false
        //        #endif
        
        super.init(frame: frame)
        
        self.fontPath = fontPath
        
        // tintColor = AppTheme.Colors.controlTinted
        
        switch gestureType {
        case .gesture(let gestureRecognizer):
            gestureRecognizer.addTarget(self, action: #selector(self.presentImGui))
        case .shake:
            break
        }
    }
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Shaking & Gestures
	public override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		
		if motion == .motionShake {
			shaking = true
			
            #if targetEnvironment(simulator)
            if self.shouldPresentImGui {
                if !self.presentImGui() { self.dismissImGui() }
            }
            #else
            DispatchQueue.main.asyncAfter(deadline: .now() + ImGuiWindow.shakeWindowTimeInterval, execute: {
                if self.shouldPresentImGui {
                    if !self.presentImGui() { self.dismissImGui() }
                }
            })
            #endif
		}
		
		super.motionBegan(motion, with: event)
	}
	
	public override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			shaking = false
		}
		
		super.motionEnded(motion, with: event)
	}
	
	// MARK: Presenting & Dismissing
	
	@objc public func presentImGui() -> Bool {
        
        if let _ = sceneView {
            let prev = ImGui.hidden
            if prev {
                ImGui.hidden = false
                return true
            }
            return false
        }
		
		guard let rootViewController = rootViewController else {
			return true
		}
        
		var visibleViewController = rootViewController
		
		while (visibleViewController.presentedViewController != nil) {
			visibleViewController = visibleViewController.presentedViewController!
		}
		
		if !(visibleViewController is ImGuiViewControllerProtocol) {
			imguiViewController.providesPresentationContextTransitionStyle = true
			imguiViewController.definesPresentationContext = true
			imguiViewController.modalPresentationStyle = .overCurrentContext
			imguiViewController.view.backgroundColor = .clear
            imguiViewController.view.frame = visibleViewController.view.frame
            imguiViewController.modalPresentationStyle = .custom
            imguiViewController.transitioningDelegate = self
            
            
			visibleViewController.present(imguiViewController, animated: true, completion: nil)
			return true
		} else {
			return false
		}
	}
	
	@objc public func dismissImGui(completion: (() -> ())? = nil) {
        
        if let _ = sceneView {
            ImGui.hidden = true
            completion?()
        } else {
            imguiViewController.dismiss(animated: true, completion: completion)
        }
	}
}

extension ImGuiWindow: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = AdjustableSizePresentationContrller(presentedViewController: presented, presenting: presenting)
        controller.frame = frameOverride != nil ? frameOverride! : presenting!.view.frame
        return controller
    }
}

class AdjustableSizePresentationContrller: UIPresentationController {
    var frame: CGRect = CGRect.zero
    override var frameOfPresentedViewInContainerView: CGRect {
        return frame
    }
}

//extension ImGuiWindow: ImGuiViewControllerDelegate {
//    public func imguiViewControllerRequestsDismiss(imguiViewController: ImGuiViewController, completion: (() -> ())? = nil) {
//        dismissImGui(completion: completion)
//    }
//}

