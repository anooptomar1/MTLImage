//
//  Levels.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/2/16.
//
//

import UIKit

struct LevelsUniforms: Uniforms {
    var min: Float = 0.0
    var mid: Float = 0.5
    var max: Float = 1.0
    var minOut: Float = 0.0
    var maxOut: Float = 1.0
}

public
class Levels: Filter {
    var uniforms = LevelsUniforms()
    
    public var min: Float = 0.0 {
        didSet {
            clamp(&min, low: 0, high: mid)
            needsUpdate = true
        }
    }
    
    public var mid: Float = 0.5 {
        didSet {
            clamp(&mid, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var max: Float = 1.0 {
        didSet {
            clamp(&max, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var minOut: Float = 0.0 {
        didSet {
            clamp(&minOut, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var maxOut: Float = 1.0 {
        didSet {
            clamp(&maxOut, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public override func reset() {
        min = 0.0
        mid = 0.5
        max = 1.0
        minOut = 0.0
        maxOut = 1.0
    }
    
    public init() {
        super.init(functionName: "levels")
        title = "Levels"
        properties = [
            Property<Levels, Float>(title: "Minimum", keyPath: \Levels.min),
            Property<Levels, Float>(title: "Middle", keyPath: \Levels.mid),
            Property<Levels, Float>(title: "Maximum", keyPath: \Levels.max),
            Property<Levels, Float>(title: "Minimum Output", keyPath: \Levels.minOut),
            Property<Levels, Float>(title: "Maximum Output", keyPath: \Levels.maxOut)
        ]
    }

    override func update() {
        if self.input == nil { return }
        uniforms.min = min
        uniforms.mid = Tools.convert(mid, oldMin: 0.0, oldMid: 0.5, oldMax: 1.0, newMin: 0.0, newMid: 1.0, newMax: 10.0)
        uniforms.max = max
        uniforms.minOut = minOut
        uniforms.maxOut = maxOut
        updateUniforms(uniforms: uniforms)
    }

}
