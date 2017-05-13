//
//  ImGuiWindow.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 10/24/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

import UIKit

@objc public final class ImGuiWindow: UIWindow {
	
	public enum GestureType {
		case Shake
		case Gesture(UIGestureRecognizer)
	}
	
	/// The amount of time you need to shake your device to bring up the ImGui UI
	private static let shakeWindowTimeInterval: Double = 0.4
	
	/// The GestureType used to determine when to present the UI.
	private let gestureType: GestureType
	
	/// By holding on to the ImGuiViewController, we get easy state restoration!
	public var imguiViewController: ImGuiViewController! // requires self for init
	
	/// Whether or not the device is shaking. Used in determining when to present the ImGui UI when the device is shaken.
	private var shaking: Bool = false
	
	private var shouldPresentImGui: Bool {
		switch gestureType {
		case .Shake: return shaking
		case .Gesture: return true
		}
	}
	
	// MARK: Init
	
	public init(frame: CGRect, gestureType: GestureType = .Shake) {
		self.gestureType = gestureType
		
//		// Are we running on a Mac? If so, then we're in a simulator!
//		#if (arch(i386) || arch(x86_64))
//			self.runningInSimulator = true
//		#else
//			self.runningInSimulator = false
//		#endif
		
		super.init(frame: frame)
		
		// tintColor = AppTheme.Colors.controlTinted
		
		switch gestureType {
		case .Gesture(let gestureRecognizer):
			gestureRecognizer.addTarget(self, action: #selector(self.presentImGui))
		case .Shake:
			break
		}
		
		imguiViewController = ImGuiViewController(delegate: self)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Shaking & Gestures
	public override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
		
		if motion == .motionShake {
			shaking = true
			
			DispatchQueue.main.asyncAfter(deadline: .now() + ImGuiWindow.shakeWindowTimeInterval, execute: {
				if self.shouldPresentImGui {
					if !self.presentImGui() {
						self.dismissImGui()
					}
				}
			})
		}
		
		super.motionBegan(motion, with: event)
	}
	
	public override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			shaking = false
		}
		
		super.motionEnded(motion, with: event)
	}
	
	// MARK: Presenting & Dismissing
	
	@objc private func presentImGui() -> Bool {
		
		guard let rootViewController = rootViewController else {
			return true
		}
		
		var visibleViewController = rootViewController
		
		while (visibleViewController.presentedViewController != nil) {
			visibleViewController = visibleViewController.presentedViewController!
		}
		
		if !(visibleViewController is ImGuiViewController) {
			imguiViewController.providesPresentationContextTransitionStyle = true
			imguiViewController.definesPresentationContext = true
			imguiViewController.modalPresentationStyle = .overCurrentContext
			imguiViewController.view.backgroundColor = .clear
			visibleViewController.present(imguiViewController, animated: true, completion: nil)
			return true
		} else {
			return false
		}
	}
	
	func dismissImGui(completion: (() -> ())? = nil) {
		imguiViewController.dismiss(animated: true, completion: completion)
	}
	
	func addDrawBlock(drawBlock: @escaping (ImGuiBase) -> Void) {
		imguiViewController.imguiView.drawBlocks.append(drawBlock)
	}
}

extension ImGuiWindow: ImGuiViewControllerDelegate {
	public func imguiViewControllerRequestsDismiss(imguiViewController: ImGuiViewController, completion: (() -> ())? = nil) {
		dismissImGui(completion: completion)
	}
}
