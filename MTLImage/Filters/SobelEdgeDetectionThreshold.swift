//
//  SobelEdgeDetectionThreshold.swift
//  Pods
//
//  Created by Mohssen Fathi on 5/9/16.
//
//

import UIKit

struct SobelEdgeDetectionThresholdUniforms: Uniforms {
    var threshold: Float = 0.5;
}

public
class SobelEdgeDetectionThreshold: Filter {
    
    var uniforms = SobelEdgeDetectionThresholdUniforms()
    let sobelEdgeDetectionFilter = SobelEdgeDetection()
    
    public var threshold: Float = 0.5 {
        didSet {
            clamp(&threshold, low: 0, high: 1)
            needsUpdate = true
        }
    }
    
    public var edgeStrength: Float = 0.0 {
        didSet {
            sobelEdgeDetectionFilter.edgeStrength = edgeStrength
        }
    }
    
    public init() {
        super.init(functionName: "sobelEdgeDetectionThreshold")
        title = "Sobel Edge Detection Threshold"
        properties = [
            Property<SobelEdgeDetectionThreshold, Float>(title: "Threshold", keyPath: \SobelEdgeDetectionThreshold.threshold),
            Property<SobelEdgeDetectionThreshold, Float>(title: "Edge Strength", keyPath: \SobelEdgeDetectionThreshold.edgeStrength)
        ]
        
        sobelEdgeDetectionFilter.addTarget(self)
        input = sobelEdgeDetectionFilter
        
        update()
    }

    override func update() {
        if self.input == nil { return }
        
        uniforms.threshold = threshold
        updateUniforms(uniforms: uniforms)
    }
    
    public override func process() {
        super.process()
        sobelEdgeDetectionFilter.process()
    }
    
}
