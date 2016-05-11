//
//  MTLLineDetectionFilter.swift
//  Pods
//
//  Created by Mohssen Fathi on 5/9/16.
//
//

import UIKit

struct MTLLineDetectionUniforms {
    var sensitivity: Float = 0.5;
}

public
class MTLLineDetectionFilter: MTLFilter {
    
    var uniforms = MTLLineDetectionUniforms()
    
    private var accumulatorBuffer: MTLBuffer!
    private var inputSize: CGSize?
    private let sobelEdgeDetectionThreshold = MTLSobelEdgeDetectionThresholdFilter()
    private let thetaCount: Int = 180
    lazy private var accumulator: [Float] = {
        return [Float](count: Int(self.inputSize!.width) * self.thetaCount, repeatedValue: 0.0)
    }()
    
    public var sensitivity: Float = 0.5 {
        didSet {
            clamp(&sensitivity, low: 0, high: 1)
            needsUpdate = true
            update()
        }
    }
    
    public init() {
        super.init(functionName: "lineDetection")
        title = "Line Detection"
        properties = [MTLProperty(key: "sensitivity", title: "Sensitivity")]
        
        sobelEdgeDetectionThreshold.addTarget(self)
        internalInput = sobelEdgeDetectionThreshold
        
        update()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func update() {
        if self.input == nil { return }
        
        if inputSize == nil {
            inputSize = context.processingSize
        }
        else {
            if accumulatorBuffer != nil {
                let length = Int(inputSize!.width) * thetaCount
                let data = NSData(bytesNoCopy: accumulatorBuffer!.contents(), length:length, freeWhenDone: false)
                data.getBytes(&accumulator, length:length)
//                print(accumulator)
                
                let m = accumulator.maxElement()
                print(m)
            }
        }
        
        uniforms.sensitivity = sensitivity
        uniformsBuffer = device.newBufferWithBytes(&uniforms, length: sizeof(MTLLineDetectionUniforms), options: .CPUCacheModeDefaultCache)
    }
    
    override func configureCommandEncoder(commandEncoder: MTLComputeCommandEncoder) {
        super.configureCommandEncoder(commandEncoder)
        
        let accumulator = [Float](count: Int(inputSize!.width) * thetaCount, repeatedValue: 0)
        accumulatorBuffer = device.newBufferWithBytes(accumulator,
                                                      length: accumulator.count * sizeofValue(accumulator[0]),
                                                      options: .CPUCacheModeDefaultCache)
        commandEncoder.setBuffer(accumulatorBuffer, offset: 0, atIndex: 1)
    }
    
    public override func process() {
        super.process()
        sobelEdgeDetectionThreshold.process()
    }
    
    public override var input: MTLInput? {
        get {
            return internalInput
        }
        set {
            if newValue?.identifier != sobelEdgeDetectionThreshold.identifier {
                sobelEdgeDetectionThreshold.input = newValue
                setupPipeline()
                update()
            }
        }
    }
    
}
