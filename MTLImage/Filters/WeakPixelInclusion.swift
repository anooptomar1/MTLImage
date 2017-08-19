//
//  WeakPixelInclusion.swift
//  Pods
//
//  Created by Mohssen Fathi on 5/11/16.
//
//

import UIKit

struct WeakPixelInclusionUniforms: Uniforms {
    
}

public
class WeakPixelInclusion: Filter {
    
    var uniforms = WeakPixelInclusionUniforms()
    
    public init() {
        super.init(functionName: "weakPixelInclusion")
        title = "Weak Pixel Inclusion"
        properties = []
        update()
    }

    override func update() {
        if self.input == nil { return }
        updateUniforms(uniforms: uniforms)
    }
    
}
