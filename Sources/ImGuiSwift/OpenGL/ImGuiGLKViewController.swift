//
//  ImGuiGLKViewController.swift
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

public class ImGuiGLKViewController: GLKViewController, ImGuiViewControllerProtocol {

    public var imgui: ImGuiBase!
    var context: EAGLContext!
    
    public var drawBlocks: [ImGuiDrawCallback] = []
    
    public var backgroundColor = UIColor.clear {
        willSet (newValue){
            newValue.getRed(&glRed, green: &glGreen, blue: &glBlue, alpha: &glAlpha)
        }
    }
    
    private var glRed: CGFloat = 1.0
    private var glGreen: CGFloat = 1.0
    private var glBlue: CGFloat = 1.0
    private var glAlpha: CGFloat = 1.0
    
    var fontPath: String?
    
    public convenience init(fontPath: String? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.fontPath = fontPath
    }
 
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        view.layer.isOpaque = false
        
        context = EAGLContext(api: .openGLES2)
        
        if let glkView = view as? GLKView, let _context = context {
            glkView.context = _context
            glkView.drawableDepthFormat = .format24
            
            if let fontPath = fontPath {
                imgui = ImGuiOpenGL(view: glkView, fontPath: fontPath)
            } else {
                imgui = ImGuiOpenGL(view: glkView)
            }
            imgui.setupGestures(view: view)
        }
    }
    
    override public func loadView() {
        view = GLKView()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: glkView
    override public func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        glClearColor(GLfloat(glRed), GLfloat(glGreen), GLfloat(glBlue), GLfloat(glAlpha))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        guard let imgui = imgui as? ImGuiOpenGL else { return }
        imgui.setViewport(size: view.bounds.size, scale: UIScreen.main.scale)
        imgui.newFrame()
        for block in drawBlocks {
            block(imgui)
        }
        imgui.render()
    }
}


