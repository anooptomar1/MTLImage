//
//  MTLSaturationFilter.swift
//  Pods
//
//  Created by Mohammad Fathi on 3/10/16.
//
//

import UIKit

struct CrossHatchUniforms {
    var crossHatchSpacing: Float = 0.03;
    var lineWidth: Float = 0.003;
}

public
class MTLCrossHatchFilter: MTLFilter {
    
    var uniforms = CrossHatchUniforms()
    
    public var crossHatchSpacing: Float = 0.5 {
        didSet {
            clamp(&crossHatchSpacing, low: 0, high: 1)
            dirty = true
            update()
        }
    }
    
    public var lineWidth: Float = 0.5 {
        didSet {
            clamp(&lineWidth, low: 0, high: 1)
            dirty = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "crossHatch")
        title = "Cross Hatch"
        properties = [ MTLProperty(key: "crossHatchSpacing", title: "Cross Hatch Spacing", type: Float()),
                       MTLProperty(key: "lineWidth"        , title: "Line Width"         , type: Float())]
        update()
    }
    
    override func update() {
        if self.input == nil { return }
        
        var chs = Tools.convert(crossHatchSpacing, oldMin: 0, oldMax: 1, newMin: 0.01, newMax: 0.08)
        if uniformsBuffer != nil && texture != nil {
            var singlePixelSpacing: Float!
            if texture!.width != 0 { singlePixelSpacing = 1.0 / Float(texture!.width) }
            else                  { singlePixelSpacing = 1.0 / 2048.0               }
            if (chs < singlePixelSpacing) { chs = singlePixelSpacing }
        }
        
        uniforms.crossHatchSpacing = chs
        uniforms.lineWidth = Tools.convert(lineWidth, oldMin: 0, oldMax: 1, newMin: 0.001, newMax: 0.008)
        uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(CrossHatchUniforms), options: .CPUCacheModeDefaultCache)
    }    
}