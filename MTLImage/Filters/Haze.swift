//
//  Haze.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/8/16.
//
//

import UIKit

struct HazeUniforms: Uniforms {
    var distance: Float = 0.5
    var slope: Float = 0.5;
}

public
class Haze: Filter {
    
    var uniforms = HazeUniforms()
    
    public var fade: Float = 0.0 {
        didSet {
            clamp(&fade, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public init() {
        super.init(functionName: "haze")
        title = "Haze"
        properties = [
            Property<Haze, Float>(title: "Fade", keyPath: \Haze.fade)
        ]
        update()
    }
    
    override func update() {
        if self.input == nil { return }
        uniforms.distance = -fade
//        uniforms.slope = slope  //distance * 0.6 - 0.3
        updateUniforms(uniforms: uniforms)
    }
    
}
