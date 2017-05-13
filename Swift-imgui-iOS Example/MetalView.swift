//
//  MetalView.swift
//  MetalKitDemo
//
//  Created by Hiroaki Yamane on 10/1/16.
//  Copyright © 2016 Hiroaki Yamane. All rights reserved.
//

import MetalKit

public class MetalView: NSObject, MTKViewDelegate {
	
	public var device: MTLDevice!
	public var commandQueue: MTLCommandQueue!
	var rps: MTLRenderPipelineState!
	var vertexBuffer: MTLBuffer!
	var uniformBuffer: MTLBuffer!
	var indexBuffer: MTLBuffer!
	var viewportUniformBuffer: MTLBuffer!
	var rotation: Float = 0
	var comboIndex: Int32 = 0
	var selectedName: String = ""
	var animate: Bool = true
	var lastRefreshTime: Float = 0.0
	var startTime: Float = 0.0
	var phase: Float = 0.0
	
	var comboOptionItems = [
		"Option A",
		"Option B",
		"Option C"
	]

	var imgui: ImGuiBase?
	var showWindow: Bool = true
	var radioButton: Bool = true
	var sliderInt: Int32 = 10
	var sliderFloat: Float = 0.5
	var myText = "My Test."
	var clearColor = UIColor.white
	
	var aspect: Float = 1.0
	
	override public init() {
		super.init()
		startTime = Float(CFAbsoluteTimeGetCurrent())
		device = MTLCreateSystemDefaultDevice()
		commandQueue = device!.makeCommandQueue()
		createBuffers()
		registerShaders()
	}
	
	func createBuffers() {
		let vertexData = [
			Vertex(pos: [-1.0, -1.0,  1.0, 1.0], col: [1, 1, 1, 1]),
			Vertex(pos: [ 1.0, -1.0,  1.0, 1.0], col: [1, 0, 0, 1]),
			Vertex(pos: [ 1.0,  1.0,  1.0, 1.0], col: [1, 1, 0, 1]),
			Vertex(pos: [-1.0,  1.0,  1.0, 1.0], col: [0, 1, 0, 1]),
			Vertex(pos: [-1.0, -1.0, -1.0, 1.0], col: [0, 0, 1, 1]),
			Vertex(pos: [ 1.0, -1.0, -1.0, 1.0], col: [1, 0, 1, 1]),
			Vertex(pos: [ 1.0,  1.0, -1.0, 1.0], col: [0, 0, 0, 1]),
			Vertex(pos: [-1.0,  1.0, -1.0, 1.0], col: [0, 1, 1, 1])]
		
		let indexData: [UInt16] = [0, 1, 2, 2, 3, 0,   // front
			1, 5, 6, 6, 2, 1,   // right
			3, 2, 6, 6, 7, 3,   // top
			4, 5, 1, 1, 0, 4,   // bottom
			4, 0, 3, 3, 7, 4,   // left
			7, 6, 5, 5, 4, 7]   // back
		
		vertexBuffer = device!.makeBuffer(bytes: vertexData, length: MemoryLayout<Vertex>.size * vertexData.count, options: [])
		indexBuffer = device!.makeBuffer(bytes: indexData, length: MemoryLayout<UInt16>.size * indexData.count , options: [])
		uniformBuffer = device!.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
	}
	
	func registerShaders() {
		
		let library: MTLLibrary
		let vertFunc: MTLFunction
		let fragFunc: MTLFunction
		do {
			library = device!.newDefaultLibrary()!
			vertFunc = library.makeFunction(name: "vertex_func")!
			fragFunc = library.makeFunction(name: "fragment_func")!
			let rpld = MTLRenderPipelineDescriptor()
			rpld.vertexFunction = vertFunc
			rpld.fragmentFunction = fragFunc
			rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
			rps = try device!.makeRenderPipelineState(descriptor: rpld)
		} catch let error {
			Swift.print("\(error)")
		}
	}
	
	func update() {
		let scaled = scalingMatrix(scale: sliderFloat)
		rotation += 1 / 100 * Float(M_PI) / 4
		let rotatedY = rotationMatrix(angle: rotation, axis: float3(0, 1, 0))
		let rotatedX = rotationMatrix(angle: Float(M_PI) / 4, axis: float3(1, 0, 0))
		let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
		let cameraPosition = vector_float3(0, 0, -3)
		let viewMatrix = translationMatrix(position: cameraPosition)
		let projMatrix = projectionMatrix(near: 0, far: 10, aspect: aspect, fovy: 1)
		let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
		let bufferPointer = uniformBuffer.contents()
		var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
		memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
	}
	
	public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
	}
	
	public func draw(in view: MTKView) {
		
		aspect = Float(view.bounds.size.width / view.bounds.size.height)
		
		update()
		
		if let rpd = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
			
			let components = clearColor.cgColor.components!.map({ (v) -> Double in
				return Double(v)
			})
			
			let mtlClearColor = components.count < 4 ? MTLClearColorMake(components[0], components[0], components[0], components[1]) : MTLClearColorMake(components[0], components[1], components[2], components[3])
			rpd.colorAttachments[0].clearColor = mtlClearColor
			let commandBuffer = commandQueue.makeCommandBuffer()
			let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
			commandEncoder.setRenderPipelineState(rps)
			commandEncoder.setFrontFacing(.counterClockwise)
			commandEncoder.setCullMode(.back)
			commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
			commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
			commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexBuffer.length / MemoryLayout<UInt16>.size, indexType: MTLIndexType.uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
			commandEncoder.endEncoding()
			// commandBuffer.present(drawable)
			commandBuffer.commit()
			
			if let _imgui = imgui as? ImGuiMetal {
				
				_imgui.setViewport(size: view.bounds.size, scale: UIScreen.main.scale)
				_imgui.newFrame(drawable: drawable)
    			_imgui.begin(name: "My window name", show: &showWindow)
				
				let items: [UIKeyboardType] = [
					.alphabet,
					.asciiCapable,
					.asciiCapableNumberPad,
					.decimalPad,
					.default,
					.emailAddress,
					.namePhonePad,
					.numberPad,
					.numbersAndPunctuation,
					.phonePad,
					.twitter,
					.URL,
					.webSearch
				]
				
				struct Temp {
					static var index = 0
				}
				
				_ = _imgui.colorButton(color: .red)
				_ = _imgui.colorButton(color: .green)
				_ = _imgui.colorButton(color: .blue)
				
				let red2 = UIColor.red.withAlphaComponent(0.5)
				let green2 = UIColor.green.withAlphaComponent(0.5)
				let blue2 = UIColor.blue.withAlphaComponent(0.5)
				_ = 	_imgui.colorButton(color: red2)
				_imgui.sameLine()
				_ = 	_imgui.colorButton(color: green2)
				_imgui.sameLine()
				_ = 	_imgui.colorButton(color: blue2)
				
				/*
				_imgui.image(image: #imageLiteral(resourceName: "non-alpha"), size: CGSize(width: 30, height: 30))
				_imgui.sameLine()
				_imgui.image(image: #imageLiteral(resourceName: "with-alpha"), size: CGSize(width: 30, height: 30))
				_imgui.sameLine()
				_imgui.image(image: #imageLiteral(resourceName: "with-alpha_copy"), size: CGSize(width: 30, height: 30))
				
				_imgui.image(image: #imageLiteral(resourceName: "red"), size: CGSize(width: 30, height: 30))
				_imgui.sameLine()
				_imgui.image(image: #imageLiteral(resourceName: "green"), size: CGSize(width: 30, height: 30))
				_imgui.sameLine()
				_imgui.image(image: #imageLiteral(resourceName: "blue"), size: CGSize(width: 30, height: 30))*/
				
				_imgui.image(image: #imageLiteral(resourceName: "sticker"), size: CGSize(width: 100, height: 100))
				
				_ = _imgui.sliderInt(label: "KeyboardType", v: &Temp.index, minV: Int32(0), maxV: Int32(items.count - 1))
				_imgui.input.textField.keyboardType = items[Int(Temp.index)]
				
				showHelp(imgui: _imgui)
				showWindowOptions(imgui: _imgui)
				showWidgets(imgui: _imgui)
    			showGraphWidgets(imgui: _imgui)
    			showLayout(imgui: _imgui)
    			showPopupsAndModalWindows(imgui: _imgui)
    			showColumns(imgui: _imgui)
    			showFiltering(imgui: _imgui)
				
    			_imgui.end()
    			_imgui.render()
		
			}
			
			let presentationBuffer = commandQueue.makeCommandBuffer()
			presentationBuffer.present(drawable)
			presentationBuffer.commit()

				
		}
	}
}
