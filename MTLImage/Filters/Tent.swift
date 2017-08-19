//
//  Tent.swift
//  Pods
//
//  Created by Mohssen Fathi on 6/18/16.
//
//

import UIKit
import MetalPerformanceShaders

public
class Tent: MPS {
    
    var radius: Float = 0.5 {
        didSet {
            clamp(&radius, low: 0, high: 1)
            kernel = MPSImageTent(device      : context.device,
                                  kernelWidth : Tools.odd(Int(radius * 100.0)),
                                  kernelHeight: Tools.odd(Int(radius * 100.0)))
            (kernel as! MPSImageTent).edgeMode = .clamp
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
        title = "Tent"
        properties = [Property<Tent, Float>(title: "Radius", keyPath: \Tent.radius)]
        radius = 0.5
    }
    
}
