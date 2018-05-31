//
//  ImGuiMetal.swift
//  Swift-imgui
//
//  Created by Hiroaki Yamane on 1/24/17.
//  Copyright © 2017 Hiroaki Yamane. All rights reserved.
//

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

#if targetEnvironment(simulator)

#else

import MetalKit
import SceneKit
//import SpriteKit


public class ImGuiMetal: ImGuiBase {
    
	var loader: MTKTextureLoader!
    var dict: [ImageAlias: MTLTexture] = [:]
    public var pixelFormat: MTLPixelFormat = .bgra8Unorm {
        didSet {
            (imguiWrapper as! ImGuiWrapperMetal).setPixelFormat(pixelFormat)
        }
    }
    
    public var depthPixelFormat: MTLPixelFormat = .depth32Float {
        didSet {
            (imguiWrapper as! ImGuiWrapperMetal).setDepthPixelFormat(depthPixelFormat)
        }
    }
    
    public init(view: MTKView, fontPath: String? = nil) {
        super.init()
		self.view = view
        if fontPath != nil {
            imguiWrapper = ImGuiWrapperMetal(device: view.device!, font: fontPath!)
        } else {
            imguiWrapper = ImGuiWrapperMetal(device: view.device!)
        }
		setupLoader(view.device!)
        setup()
	}
    
    public init(view: SCNView, fontPath: String? = nil) {
        super.init()
        self.view = view
        if fontPath != nil {
            imguiWrapper = ImGuiWrapperMetal(device: view.device!, font: fontPath!)
        } else {
            imguiWrapper = ImGuiWrapperMetal(device: view.device!)
        }
        setupLoader(view.device!)
        setup()
    }
    
    
    init(view: ViewAlias, device: MTLDevice, fontPath: String? = nil) {
        super.init()
		self.view = view
        if fontPath != nil {
            imguiWrapper = ImGuiWrapperMetal(device: device, font: fontPath!)
        } else {
            imguiWrapper = ImGuiWrapperMetal(device: device)
        }
		setupLoader(device)
        setup()
	}
    
    
    func setupLoader(_ device: MTLDevice) {
		loader = MTKTextureLoader(device: device)
    }
	
	func render(commandQueue: MTLCommandQueue? = nil, currentDrawable: CAMetalDrawable? = nil) {
		imguiWrapper.render()
		if let commandQueue = commandQueue, let currentDrawable = currentDrawable {
    		let presentationBuffer = commandQueue.makeCommandBuffer()
            #if os(iOS)
            presentationBuffer?.present(currentDrawable)
            presentationBuffer?.commit()
            #else
            presentationBuffer?.present(currentDrawable)
            presentationBuffer?.commit()
            #endif
		}
	}
    
    public func newFrame(commandEncoder: MTLRenderCommandEncoder) {
        if let imguiWrapper = imguiWrapper as? ImGuiWrapperMetal {
            imguiWrapper.newFrame(with: commandEncoder)
        }
        io = imguiWrapper.getIO() as! ImGuiIOBridge
        #if os(iOS)
            DispatchQueue.main.async {
                self.input.draw(imgui: self)
            }
        #endif
    }
    
	func newFrame(drawable:CAMetalDrawable) {
        if let imguiWrapper = imguiWrapper as? ImGuiWrapperMetal {
            imguiWrapper.newFrame(drawable)
        }
		io = imguiWrapper.getIO() as! ImGuiIOBridge
		#if os(iOS)
		input.draw(imgui: self)
		#endif
	}
    
	func setPixelFormat(pixelFormat: MTLPixelFormat) {
        if let imguiWrapper = imguiWrapper as? ImGuiWrapperMetal {
            imguiWrapper.setPixelFormat(pixelFormat)
        }
	}
    
    #if os(OSX)
	func image(image _image: NSImage, size: CGSize, uv0: CGPoint = CGPoint.zero, uv1: CGPoint = CGPoint(x: 1.0, y: 1.0), tintColor: ColorAlias = .black, borderColor: ColorAlias = ColorAlias(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)) {
		
		if let texture = dict[_image] {
			(imguiWrapper as! ImGuiWrapperMetal).image(texture, size, uv0, uv1, tintColor.cgColor, borderColor.cgColor)
		} else {
			do {
				let texture = try loader.newTexture(data: _image.tiffRepresentation!, options: nil)
				dict[_image] = texture
			} catch let err {
                print("ImGui::image\(err.localizedDescription)")
			}
		}
	}
    
    #else
	func image(image _image: UIImage, size: CGSize, uv0: CGPoint = CGPoint.zero, uv1: CGPoint = CGPoint(x: 1.0, y: 1.0), tintColor: ColorAlias = .black, borderColor: ColorAlias = ColorAlias(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)) {
		if let texture = dict[_image] {
			(imguiWrapper as! ImGuiWrapperMetal).image(texture, size, uv0, uv1, tintColor.cgColor, borderColor.cgColor)
		} else {
			do {
				let texture = try loader.newTexture(cgImage: _image.cgImage!, options: nil)
				dict[_image] = texture
			} catch let err {
                print("ImGui::image\(err.localizedDescription)")
			}
		}
	}
    
    #endif
    
}
#endif
