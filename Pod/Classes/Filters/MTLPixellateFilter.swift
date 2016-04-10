//
//  MTLPixellateFilter.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/1/16.
//
//

import UIKit

struct PixellateUniforms {
    var dotRadius: Float = 0.5;
    var aspectRatio: Float = 0.6667
    var fractionalWidthOfPixel: Float = 0.02
}

public
class MTLPixellateFilter: MTLFilter {

    var uniforms = PixellateUniforms()
    var imageSize: CGSize?
    
    public var dotRadius: Float = 0.5 {
        didSet {
            clamp(&dotRadius, low: 0, high: 1)
            dirty = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "pixellate")
        title = "Pixellate"
        properties = [MTLProperty(key: "dotRadius", title: "Dot Radius", type: Float())]
        update()
    }
    
    override func update() {
        if self.input == nil { return }
        
//        var add: Float = 0.2
//        if imageSize != nil {
//            add = Float(imageSize!.width) / 500.0
//        }
        
        uniforms.dotRadius = Tools.convert(dotRadius, oldMin: 0, oldMax: 1, newMin: 0.01, newMax: 3)
        uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(PixellateUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    override public var input: MTLInput? {
        didSet {
            if originalImage != nil {
                imageSize = originalImage?.size
                uniforms.aspectRatio = 1.0 / Float(originalImage!.size.width / originalImage!.size.height)
            }
        }
    }
    
}