//
//  MTLView.swift
//  Pods
//
//  Created by Mohssen Fathi on 3/25/16.
//
//

import UIKit
import Metal
import MetalKit

public
protocol MTLViewDelegate {
    func mtlViewTouchesBegan(sender: MTLView, touches: Set<UITouch>, event: UIEvent?)
    func mtlViewTouchesMoved(sender: MTLView, touches: Set<UITouch>, event: UIEvent?)
    func mtlViewTouchesEnded(sender: MTLView, touches: Set<UITouch>, event: UIEvent?)
}

public
class MTLView: UIView, MTLOutput, UIScrollViewDelegate {
    
    public var delegate: MTLViewDelegate?
    
    var scrollView: UIScrollView!
    var contentView: MetalLayerView!
    
    private var mtlClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 0.0)
    public var clearColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) {
        didSet {
            if      clearColor == UIColor.whiteColor() { mtlClearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0) }
            else if clearColor == UIColor.blackColor() { mtlClearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0) }
            else {
                let components = CGColorGetComponents(clearColor.CGColor)
                mtlClearColor = MTLClearColorMake(Double(components[0]), Double(components[1]), Double(components[2]), Double(components[3]))
            }
        }
    }
    
    var internalTitle: String!
    public var title: String {
        get { return internalTitle }
        set { internalTitle = newValue }
    }
    
    private var privateIdentifier: String = NSUUID().UUIDString
    public var identifier: String! {
        get { return privateIdentifier     }
        set { privateIdentifier = newValue }
    }
    
    public var frameRate: Int = 60 {
        didSet {
            Tools.clamp(&frameRate, low: 0, high: 60)
            displayLink.frameInterval = 60/frameRate
        }
    }
    
    public override var contentMode: UIViewContentMode {
        didSet {
            needsUpdateBuffers = true
        }
    }
    
    public override var bounds: CGRect {
        didSet { needsUpdateBuffers = true }
    }
    
    public override var frame: CGRect {
        didSet { needsUpdateBuffers = true }
    }
    
    public var processingSize: CGSize! {
        didSet {
            metalLayer.drawableSize = processingSize
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        title = "MTLView"
        setupPipeline()
        setupBuffers()
        setupView()
    }
    
    override public func didMoveToSuperview() {
        if superview != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(MTLView.update(_:)))
            displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        } else {
            displayLink.invalidate()
        }
    }
    
    public func layoutView() {
        setupBuffers()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMetalLayer = true
    }
    
    //    MARK: - Touch Events
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        delegate?.mtlViewTouchesBegan(self, touches: touches, event: event)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        delegate?.mtlViewTouchesMoved(self, touches: touches, event: event)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        delegate?.mtlViewTouchesEnded(self, touches: touches, event: event)
    }
    
    func update(displayLink: CADisplayLink) {
        redraw()
    }
    
    public func stopProcessing() {
        displayLink.paused = true
    }
    
    public func resumeProcessing() {
        displayLink.paused = false
    }
    
    override public class func layerClass() -> AnyClass {
        return CAMetalLayer.self
    }
    
    func setupView() {
        
        contentView = MetalLayerView(frame: bounds)
        contentView.backgroundColor = UIColor.clearColor()
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 100.0
        scrollView.delegate = self
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        
        metalLayer = contentView.layer as! CAMetalLayer
        metalLayer.device = device
        metalLayer.pixelFormat = MTLPixelFormat.BGRA8Unorm
        metalLayer.drawsAsynchronously = true
        
    }
    
    
    func setupPipeline() {
        device = context.device
        library = context.library
        vertexFunction   = library.newFunctionWithName("vertex_main")
        fragmentFunction = library.newFunctionWithName("fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        do {
            pipeline = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch {
            print("Failed to create pipeline")
        }
    }
    
    func updateMetalLayerLayout() {
        let scale = window!.screen.nativeScale
        contentScaleFactor = scale
        metalLayer.frame = bounds
        metalLayer.drawableSize = CGSizeMake(bounds.size.width * scale, bounds.size.height * scale)
    }
    
    
    let kSzQuadTexCoords = 6 * sizeof(float2)
    let kSzQuadVertices  = 6 * sizeof(float4)
    
    let kQuadTexCoords: [float2] = [ float2(0.0, 0.0),
                                     float2(1.0, 0.0),
                                     float2(0.0, 1.0),
                                    
                                     float2(1.0, 0.0),
                                     float2(0.0, 1.0),
                                     float2(1.0, 1.0) ]
    
    private var needsUpdateBuffers = true
    func setupBuffers() {
        
        if device == nil { return }
        
        var x: Float = 0.0, y: Float = 0.0
        
        if let inputTexture = input?.texture {
            let viewSize  = bounds.size
            
            let viewRatio  = viewSize.width / viewSize.height
            let imageRatio = CGFloat(inputTexture.width) / CGFloat(inputTexture.height)
            
            if imageRatio > viewRatio {  // Image is wider than view
                y = Float((viewSize.height - (viewSize.width / imageRatio)) / viewSize.height)
            }
            else if viewRatio > imageRatio { // View is wider than image
                x = Float((viewSize.width - (viewSize.height) * imageRatio) / viewSize.width)
            }
        }

        let kQuadVertices: [float4] = [ float4(-1.0 + x,  1.0 - y, 0.0, 1.0),
                                        float4( 1.0 - x,  1.0 - y, 0.0, 1.0),
                                        float4(-1.0 + x, -1.0 + y, 0.0, 1.0),
            
                                        float4( 1.0 - x,  1.0 - y, 0.0, 1.0),
                                        float4(-1.0 + x, -1.0 + y, 0.0, 1.0),
                                        float4( 1.0 - x, -1.0 + y, 0.0, 1.0) ]
        
        vertexBuffer = device.newBufferWithBytes(kQuadVertices , length: kSzQuadVertices , options: .CPUCacheModeDefaultCache)
        if texCoordBuffer == nil {
            texCoordBuffer = device.newBufferWithBytes(kQuadTexCoords, length: kSzQuadTexCoords, options: .CPUCacheModeDefaultCache)
        }
    }
    
    
    private var currentDrawable: CAMetalDrawable?
    var drawable: CAMetalDrawable? {
        if currentDrawable == nil {
            currentDrawable = metalLayer.nextDrawable()
        }
        return currentDrawable
    }
    
    func redraw() {
        
        guard let tex = input?.texture else { return }
//        if input?.texture == nil { return }
        
        dispatch_semaphore_wait(self.renderSemaphore, DISPATCH_TIME_FOREVER)
//        runAsynchronously {
        
            autoreleasepool {
                    
                guard let drawable = self.drawable else {
                    dispatch_semaphore_signal(self.renderSemaphore)
                    return
                }
                
                if self.needsUpdateBuffers == true {
                    self.setupBuffers()
                    self.updateMetalLayerLayout()
                    self.needsUpdateBuffers = false
                }
                
                if self.updateMetalLayer == true && self.window != nil {
                    self.updateMetalLayerLayout()
                    self.updateMetalLayer = false
                }
                
                let texture = drawable.texture
                
                self.renderPassDescriptor.colorAttachments[0].texture = texture
                
                let commandBuffer = self.commandQueue.commandBuffer()
                commandBuffer.label = "MTLView Buffer"
                
                let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(self.renderPassDescriptor)
                commandEncoder.pushDebugGroup("Render Texture")
                commandEncoder.setRenderPipelineState(self.pipeline)
                commandEncoder.setVertexBuffer(self.vertexBuffer  , offset: 0, atIndex: 0)
                commandEncoder.setVertexBuffer(self.texCoordBuffer, offset: 0, atIndex: 1)
                commandEncoder.setFragmentTexture(tex, atIndex: 0)
                
                commandEncoder.drawPrimitives(.Triangle , vertexStart: 0, vertexCount: 6, instanceCount: 1)
                
                commandEncoder.endEncoding()
                commandEncoder.popDebugGroup()
                
                commandBuffer.addCompletedHandler({ (commandBuffer) in
                    dispatch_semaphore_signal(self.renderSemaphore)
                    self.currentDrawable = nil
                })
                
                commandBuffer.presentDrawable(drawable)
                
                commandBuffer.commit()
//                commandBuffer.waitUntilCompleted()
                
//            }
        }
    }
    
    
    //    MARK: - UIScrollView Delegate
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
    
        guard let tex = self.input?.texture else { return }
        
        let imageSize = CGSize(width: tex.width, height: tex.height)
        let imageFrame = Tools.imageFrame(imageSize, rect: self.contentView.frame)
        
        var y = imageFrame.origin.y - (CGRectGetHeight(frame)/2 - CGRectGetHeight(imageFrame)/2)
        var x = imageFrame.origin.x - (CGRectGetWidth (frame)/2 - CGRectGetWidth (imageFrame)/2)
        y = min(imageFrame.origin.y, y)
        x = min(imageFrame.origin.x, x)
        
        scrollView.contentInset = UIEdgeInsetsMake(-y, -x, -y, -x);
    }

    public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        guard let viewSize = view?.frame.size else { return }
        
//        let maxSize = FiltersManager.sharedManager.maxProcessingSize
        let minSize = bounds.size * UIScreen.mainScreen().scale
        let ratio = viewSize.width / viewSize.height
        
//        if (viewSize.width > maxSize.width || viewSize.height > maxSize.height) {
//            mtlView.processingSize = CGSize(width: maxSize.width, height: maxSize.width / ratio)
//        }
        if (viewSize.width < minSize.width || viewSize.height < minSize.height) {
            metalLayer.drawableSize = CGSize(width: minSize.width, height: minSize.width / ratio)
        }
        else {
            metalLayer.drawableSize = viewSize
        }
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.zooming { return }
//        cropFilter.cropRegion = currentCropRegion(scrollView)
    }
    
    func currentCropRegion(scrollView: UIScrollView) -> CGRect {
        
        var x = scrollView.contentOffset.x / scrollView.contentSize.width
        var y = scrollView.contentOffset.y / scrollView.contentSize.height
        var width  = scrollView.frame.size.width / scrollView.contentSize.width
        var height = scrollView.frame.size.height / scrollView.contentSize.height
        
        Tools.clamp(&x     , low: 0, high: 1)
        Tools.clamp(&y     , low: 0, high: 1)
        Tools.clamp(&width , low: 0, high: 1.0 - x)
        Tools.clamp(&height, low: 0, high: 1.0 - y)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    //    MARK: - Queues
    
    func runSynchronously(block: (()->())) {
        dispatch_sync(context.processingQueue) {
            block()
        }
    }
    
    func runAsynchronously(block: (()->())) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            block()
        }
//        dispatch_async(context.processingQueue) {
//            block()
//        }
    }
    
//    var texture: MTLTexture? {
//        return cropFilter.texture
//    }
    
    var context: MTLContext! {
        get {
            if input?.context == nil {
                return MTLContext()
            }
            return input?.context
        }
    }
    
    //    MARK: - MTLOutput
    
    public var input: MTLInput? {
        get {
            return self.privateInput
        }
        set {
            privateInput = newValue
//            cropFilter.input = newValue
            
            if privateInput == nil {
                displayLink.paused = true
            } else {
                displayLink.paused = false
                needsUpdateBuffers = true
            }
        }
    }
    
    
    //    MARK: - Internal
    
    private var cropFilter = MTLCropFilter()
    private var privateInput: MTLInput?
    var displayLink: CADisplayLink!
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var library: MTLLibrary!
    var vertexFunction: MTLFunction!
    var fragmentFunction: MTLFunction!
    var pipeline: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var texCoordBuffer: MTLBuffer!
    
    lazy var commandQueue: MTLCommandQueue! = {
        return self.device.newCommandQueue()
    }()
    
    private var updateMetalLayer = true
    
    private var renderSemaphore: dispatch_semaphore_t = dispatch_semaphore_create(3)
    lazy var renderPassDescriptor: MTLRenderPassDescriptor = {
        let rpd = MTLRenderPassDescriptor()
        rpd.colorAttachments[0].clearColor = self.mtlClearColor
        rpd.colorAttachments[0].storeAction = .Store
        rpd.colorAttachments[0].loadAction = .Clear
        return rpd
    }()
}

class MetalLayerView: UIView {
    public override class func layerClass() -> AnyClass {
        return CAMetalLayer.self
    }
}

func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}