//
//  MTLToonFilter.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/8/16.
//
//

import UIKit

struct ToonUniforms {
    var quantizationLevels: Float = 0.5;
    var threshold: Float = 0.0
}

public
class MTLToonFilter: MTLFilter {
    var uniforms = ToonUniforms()
    
    public var quantizationLevels: Float = 0.5 {
        didSet {
            clamp(&quantizationLevels, low: 0, high: 1)
            dirty = true
            update()
        }
    }
    
    public var threshold: Float = 0.5 {
        didSet {
            clamp(&threshold, low: 0, high: 1)
            dirty = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "toon")
        title = "Toon"
        properties = [MTLProperty(key: "threshold", title: "Threshold", type: Float()),
                      MTLProperty(key: "quantizationLevels", title: "Quantization Levels", type: Float())]
        update()
    }
    
    override func update() {
        if self.input == nil { return }
        uniforms.quantizationLevels = Tools.convert(quantizationLevels, oldMin: 0, oldMax: 1, newMin: 5, newMax: 15)
        uniforms.threshold = threshold * 0.8 + 0.2
        uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(ToonUniforms), options: .CPUCacheModeDefaultCache)
    }
    
}