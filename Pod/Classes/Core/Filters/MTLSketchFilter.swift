//
//  MTLSketchFilter.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/8/16.
//
//

import UIKit

struct SketchUniforms {
    var intensity: Float = 0.5;
}

public
class MTLSketchFilter: MTLFilter {
    var uniforms = SketchUniforms()
    
    public var intensity: Float = 0.5 {
        didSet {
            clamp(&intensity, low: 0, high: 1)
            needsUpdate = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "sketch")
        title = "Sketch"
        properties = [MTLProperty(key: "intensity", title: "Intensity")]
        update()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update() {
        if self.input == nil { return }
        
        let intense = intensity * 3.0 + 0.2
//        if context.processingSize != nil {
//            intense *= Float(2048.0/context.processingSize.width)
//        }
        uniforms.intensity = intense
        
        uniformsBuffer = device.newBuffer(withBytes: &uniforms, length: MemoryLayout<SketchUniforms>.size, options: .cpuCacheModeWriteCombined)
    }
    
}