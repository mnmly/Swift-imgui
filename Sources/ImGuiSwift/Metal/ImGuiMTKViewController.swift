#if (arch(i386) || arch(x86_64)) && os(iOS)
    
#else
    
import MetalKit

public class ImGuiMTKViewController: ViewControllerAlias, ImGuiViewControllerProtocol {
    
    public var imgui: ImGuiMetal!
    public var drawBlocks: [ImGuiDrawCallback] = []
    public var backgroundColor = ColorAlias.white {
        willSet (newValue){
            newValue.getRed(&glRed, green: &glGreen, blue: &glBlue, alpha: &glAlpha)
            (view as? MTKView)?.clearColor = MTLClearColor(red: Double(glRed), green: Double(glGreen), blue: Double(glBlue), alpha: Double(glAlpha))
        }
    }
    
    var fontName: String?
    
    private var glRed: CGFloat = 1.0
    private var glGreen: CGFloat = 1.0
    private var glBlue: CGFloat = 1.0
    private var glAlpha: CGFloat = 1.0
    
	var device: MTLDevice!
	var commandQueue: MTLCommandQueue!
    
    public convenience init(fontName: String? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.fontName = fontName
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    #if os(OSX)
    public override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)!
    }
    #else
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    #endif
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
		device = MTLCreateSystemDefaultDevice()
		commandQueue = device!.makeCommandQueue()
        
        if let mtkView = view as? MTKView {
            mtkView.device = device
            mtkView.framebufferOnly = false
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            if let fontPath = Bundle.main.path(forResource: fontName, ofType: "ttf") {
                imgui = ImGuiMetal(view: mtkView, fontPath: fontPath)
            } else {
                imgui = ImGuiMetal(view: mtkView)
            }
            imgui.setupGestures(view: view)
        }
    }
    
    override public func loadView() {
        view = MTKView()
    }
}

extension ImGuiMTKViewController: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        
		if let rpd = view.currentRenderPassDescriptor, let drawable = view.currentDrawable {
            
            rpd.colorAttachments[0].clearColor = view.clearColor
            let commandBuffer = commandQueue.makeCommandBuffer()
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd)
			commandEncoder.endEncoding()
			commandBuffer.commit()
            
            #if os(OSX)
            let scale: CGFloat = NSScreen.main()?.backingScaleFactor ?? 1.0
            #else
            let scale = UIScreen.main.scale
            #endif
            
			imgui.setViewport(size: view.bounds.size, scale: scale)
			imgui.newFrame(drawable: drawable)
            for block in drawBlocks {
                block(imgui)
            }
            
			imgui.render()
            let presentationBuffer = commandQueue.makeCommandBuffer()
            presentationBuffer.present(drawable)
            presentationBuffer.commit()
        }
    }
}
#endif
