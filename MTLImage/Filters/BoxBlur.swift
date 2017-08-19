//
//  BoxConvolution.swift
//  Pods
//
//  Created by Mohssen Fathi on 6/18/16.
//
//

import MetalPerformanceShaders

public
class BoxBlur: MPS {
    
    var radius: Float = 0.5 {
        didSet {
            clamp(&radius, low: 0, high: 1)
            kernel = MPSImageBox(device      : context.device,
                                 kernelWidth : Tools.odd(Int(radius * 80.0)),
                                 kernelHeight: Tools.odd(Int(radius * 80.0)))
            (kernel as! MPSImageBox).edgeMode = .clamp
            needsUpdate = true
        }
    }
    
    
    init() {
        super.init(functionName: nil)
        commonInit()
    }
    
    override init(functionName: String?) {
        super.init(functionName: nil)
        commonInit()
    }
    
    func commonInit() {
        kernel = MPSImageBox(device      : context.device,
                             kernelWidth : Tools.odd(Int(radius * 80.0)),
                             kernelHeight: Tools.odd(Int(radius * 80.0)))
        (kernel as! MPSImageBox).edgeMode = .clamp
        
        title = "Box Blur"
        properties = [Property<BoxBlur, Float>(title: "Radius", keyPath: \BoxBlur.radius)]
    }
    
}
