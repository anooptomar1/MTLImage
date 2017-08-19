//
//  Smudge.swift
//  Pods
//
//  Created by Mohssen Fathi on 5/26/16.
//
//

import UIKit

struct SmudgeUniforms: Uniforms {
    var radius: Float = 0.5
    var x: Float = 0.0
    var y: Float = 0.0
    var dx: Float = 0.0
    var dy: Float = 0.0
    var force: Float = 0.0
}

public
class Smudge: Filter {
    
    var uniforms = SmudgeUniforms()
    
    public var radius: Float = 0.5 {
        didSet {
            clamp(&radius, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var force: Float = 0.5 {
        didSet {
            clamp(&radius, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var location: CGPoint = CGPoint.zero {
        didSet {
            needsUpdate = true
        }
    }
    
    public var direction: CGPoint = CGPoint.zero {
        didSet {
//            direction.x = direction.x < 0 ? -1 : 1
//            direction.y = direction.y < 0 ? -1 : 1
            needsUpdate = true
        }
    }
    
    private var viewSize: CGSize!
    
    public init() {
        super.init(functionName: "smudge")
        title = "Smudge"
        properties = [
            Property<Smudge, Float>(title: "Radius", keyPath: \Smudge.radius),
            Property<Smudge, Float>(title: "Force", keyPath: \Smudge.force),
            Property<Smudge, CGPoint>(title: "Location", keyPath: \Smudge.location),
            Property<Smudge, CGPoint>(title: "Direction", keyPath: \Smudge.direction),
        ]
    }

    override func update() {
        if self.input == nil { return }
        
        if viewSize != nil {
            uniforms.x = Float(location.x/viewSize!.width)
            uniforms.y = Float(location.y/viewSize!.height)
        } else {
            if let mtlView = outputView {
                viewSize = mtlView.frame.size
            }
        }
        
        uniforms.radius = radius * 100
        uniforms.force = force
        uniforms.dx = Float(direction.x)
        uniforms.dy = Float(direction.y)
        
        updateUniforms(uniforms: uniforms)
    }
    
    
    var accumulatedTexture: MTLTexture?
//    override var inputTexture: MTLTexture? {
//        get {
//            if accumulatedTexture == nil {
//                accumulatedTexture = input?.texture
//            }
//            return accumulatedTexture
//        }
//    }
    
    public override func process() {
        super.process()
        accumulatedTexture = texture
    }
    
    public override func reset() {
        super.reset()
        accumulatedTexture = nil
    }
    
    
    
}
