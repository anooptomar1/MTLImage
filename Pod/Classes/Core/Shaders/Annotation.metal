//
//  Annotation.metal
//  MTLImage
//
//  Created by Mohssen Fathi on 12/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct AnnotationUniforms {
    float pointRadius;
    float numberOfPoints;
};

kernel void annotation(texture2d<float, access::read>  inTexture         [[ texture(0) ]],
                       texture2d<float, access::write> outTexture        [[ texture(1) ]],
                       constant AnnotationUniforms    &uniforms          [[ buffer(0) ]],
                       device float                   *pointsBuffer      [[ buffer(1) ]],
                       uint2 gid                                         [[ thread_position_in_grid ]])
{
    
    float radius = uniforms.pointRadius;
    uint x, y;
    
    for (int i = 0; i < uniforms.numberOfPoints; i++) {
        x = uint(pointsBuffer[i * 2 + 0]);
        y = uint(pointsBuffer[i * 2 + 1]);
        if (distance(float2(gid), float2(x, y)) < radius) {
            outTexture.write(float4(1, 0, 0, 1), gid);
            return;
        }
    }
    
    float4 color = inTexture.read(gid);
    outTexture.write(color, gid);
}
