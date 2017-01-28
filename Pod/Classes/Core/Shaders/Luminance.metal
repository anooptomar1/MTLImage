//
//  Luminance.metal
//  MTLImage
//
//  Created by Mohssen Fathi on 1/28/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct LuminanceUniforms {
    float threshold1;
    float threshold2;
    float threshold3;
    float threshold4;
};

kernel void luminance(texture2d<float, access::read>  inTexture     [[texture(0)]],
                      texture2d<float, access::write> outTexture    [[texture(1)]],
                      constant LuminanceUniforms &uniforms [[ buffer(0) ]],
                      uint2 gid                                     [[thread_position_in_grid]])
{
    float4 color = inTexture.read(gid);
    float luminance = dot(color.rgb, float3(0.2125, 0.7154, 0.0721));
    
    float thresholdResult;
    if (luminance < uniforms.threshold1) {
        thresholdResult = 0.0;
    }
    else if (luminance < uniforms.threshold2) {
        thresholdResult = uniforms.threshold2;
    }
    else if (luminance < uniforms.threshold3) {
        thresholdResult = uniforms.threshold3;
    }
    else if (luminance < uniforms.threshold4) {
        thresholdResult = uniforms.threshold4;
    }
    else {
        thresholdResult = 1.0;
    }
    
    outTexture.write(float4(float3(thresholdResult), color.a), gid);
}
