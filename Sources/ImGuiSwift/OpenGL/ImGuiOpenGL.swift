//
//  ImGuiOpenGL.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

import GLKit

public class ImGuiOpenGL: ImGuiBase {
    
	var dict: [ImageAlias: GLenum] = [:]
    
    public init(view: GLKView, fontPath: String? = nil) {
        super.init()
		self.view = view
        
        imguiWrapper = ImGuiWrapperOpenGLES2(view: view, font: fontPath)
		setup()
	}
    
	public func newFrame() {
		(imguiWrapper as! ImGuiWrapperOpenGLES2).newFrame()
        io = imguiWrapper.getIO() as? ImGuiIOBridge
		#if os(iOS)
		input.draw(imgui: self)
		#endif
	}
    
    /*
	public func image(image _image: UIImage, size: CGSize, uv0: CGPoint = CGPoint.zero, uv1: CGPoint = CGPoint(x: 1.0, y: 1.0), tintColor: SKColor = .black, borderColor: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)) {
		if let texture = dict[_image] {
			(imguiWrapper as! ImGuiWrapperOpenGLES2).image(GLint(texture), size, uv0, uv1, tintColor.cgColor, borderColor.cgColor)
		} else {
			do {
                let texInfo = try GLKTextureLoader.texture(with: _image.cgImage!, options: nil)
                dict[_image] = texInfo.target
			} catch let err {
                print("ImGui::image\(err.localizedDescription)")
			}
		}
	}*/
}
