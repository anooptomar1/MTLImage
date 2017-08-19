//
//  NonMaximumSuppression.swift
//  Pods
//
//  Created by Mohssen Fathi on 5/11/16.
//
//

import UIKit

struct NonMaximumSuppressionUniforms: Uniforms {
    var texelWidth: Float = 0.5;
    var texelHeight: Float = 0.5;
    var lowerThreshold: Float = 0.5;
    var upperThreshold: Float = 0.5;
}

public
class NonMaximumSuppression: Filter {
    
    var uniforms = NonMaximumSuppressionUniforms()
    
    public var lowerThreshold: Float = 0.5 {
        didSet {
            clamp(&lowerThreshold, low: 0, high: 1)
            needsUpdate = true
            update()
        }
    }
    
    public var upperThreshold: Float = 0.5 {
        didSet {
            clamp(&upperThreshold, low: 0, high: 1)
            needsUpdate = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "nonMaximumSuppression")
        title = "Non Maximum Suppression"
        properties = [
            Property<NonMaximumSuppression, Float>(title: "Lower Threshold", keyPath: \NonMaximumSuppression.lowerThreshold),
            Property<NonMaximumSuppression, Float>(title: "Upper Threshold", keyPath: \NonMaximumSuppression.upperThreshold)
        ]
    }

    override func update() {
        if self.input == nil { return }
        
        uniforms.lowerThreshold = lowerThreshold
        uniforms.upperThreshold = upperThreshold
        uniforms.texelWidth = 1.0;
        uniforms.texelHeight = 1.0;
        
        updateUniforms(uniforms: uniforms)
    }
    
}


// Threshold

struct NonMaximumSuppressionThreshodUniforms: Uniforms {
    var threshold: Float = 0.5;
}

public
class NonMaximumSuppressionThreshod: Filter {
    
    var uniforms = NonMaximumSuppressionThreshodUniforms()
    
    public var threshold: Float = 0.5 {
        didSet {
            clamp(&threshold, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public init() {
        super.init(functionName: "nonMaximumSuppressionThreshold")
        title = "Non Maximum Suppression Threshold"
        properties = [Property<NonMaximumSuppressionThreshod, Float>(title: "Threshold", keyPath: \NonMaximumSuppressionThreshod.threshold)]
    }

    override func update() {
        if self.input == nil { return }
        uniforms.threshold = threshold/5.0 + 0.01
        updateUniforms(uniforms: uniforms)
    }
    
}

