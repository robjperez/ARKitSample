//
//  YCbCr-Shader.metal
//  testMtlTexture
//
//  Created by Roberto Perez Cubero on 26/09/2017.
//  Copyright © 2017 tokbox. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void YUVColorConversion(texture2d<uint, access::read> yTexture [[texture(0)]],
                                 texture2d<uint, access::read> uTexture [[texture(1)]],
                                 texture2d<uint, access::read> vTexture [[texture(2)]],
                                 texture2d<float, access::write> outTexture [[texture(3)]],
                                 uint2 gid [[thread_position_in_grid]])
{
    float3 colorOffset = float3(-(16.0/255.0), -0.5, -0.5);
    float3x3 colorMatrix = float3x3(
                                    float3(1.164,  1.164, 1.164),
                                    float3(0.000, -0.392, 2.017),
                                    float3(1.596, -0.813, 0.000)
                                    );
    
    uint2 cbcrCoordinates = uint2(gid.x / 2, gid.y / 2); // half the size because we are using a 4:2:0 chroma subsampling
    
    float y = yTexture.read(gid).r / 255.0;
    float u = uTexture.read(cbcrCoordinates).r / 255.0;
    float v = vTexture.read(cbcrCoordinates).r / 255.0;
    
    float3 ycbcr = float3(y, u, v);
    
    float3 rgb = colorMatrix * (ycbcr + colorOffset);
    
    outTexture.write(float4(float3(rgb), 1.0), gid);
}
