//
//  VideoRender.swift
//  testMtlTexture
//
//  Created by Roberto Perez Cubero on 26/09/2017.
//  Copyright © 2017 tokbox. All rights reserved.
//

import Foundation
import OpenTok
import MetalKit
import SceneKit

class ARVideoRender : NSObject, OTVideoRender {
    private let device = MTLCreateSystemDefaultDevice()!
    let node: SCNNode
    var outTexture: MTLTexture?
    var yTexture: MTLTexture?
    var uTexture: MTLTexture?
    var vTexture: MTLTexture?
    var textureDesc: MTLTextureDescriptor?
    var defaultLibrary: MTLLibrary?
    var commandQueue: MTLCommandQueue?
    var threadsPerThreadgroup:MTLSize!
    var threadgroupsPerGrid: MTLSize!
    var pipelineState: MTLComputePipelineState!
    
    init(_ node: SCNNode) {
        self.node = node
        
        defaultLibrary = device.makeDefaultLibrary()
        commandQueue = device.makeCommandQueue()
        
        let kernelFunction = defaultLibrary?.makeFunction(name: "YUVColorConversion")
        pipelineState = try! device.makeComputePipelineState(function: kernelFunction!)
        
        threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
        threadgroupsPerGrid = MTLSizeMake(2048 / threadsPerThreadgroup.width, 1536 / threadsPerThreadgroup.height, 1)
    }
    
    func renderVideoFrame(_ frame: OTVideoFrame) {
        guard let planes = frame.planes else { return }
        guard let format = frame.format else { return }
        
        if outTexture == nil || textureDesc == nil ||
            textureDesc!.width != format.imageWidth || textureDesc!.height != format.imageHeight {
            print("Recreating textures")
            print("old: \(textureDesc?.width), new: \(format.imageWidth)")
            textureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba16Float, width: Int(format.imageWidth), height: Int(format.imageHeight), mipmapped: false)
            textureDesc?.usage = [.shaderWrite, .shaderRead]
            
            outTexture = device.makeTexture(descriptor: textureDesc!)            
            node.geometry?.firstMaterial?.diffuse.contents = outTexture!
            
            let yTextureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Uint, width: Int(format.imageWidth), height: Int(format.imageHeight), mipmapped: false)
            yTexture = device.makeTexture(descriptor: yTextureDesc)
            
            let uTextureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Uint, width: Int(format.imageWidth) / 2, height: Int(format.imageHeight) / 2, mipmapped: false)
            uTexture = device.makeTexture(descriptor: uTextureDesc)
            
            let vTextureDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Uint, width: Int(format.imageWidth) / 2, height: Int(format.imageHeight) / 2, mipmapped: false)
            vTexture = device.makeTexture(descriptor: vTextureDesc)
        }
        
        yTexture!.replace(region: MTLRegionMake2D(0, 0, Int(format.imageWidth), Int(format.imageHeight)),
                        mipmapLevel: 0,
                        withBytes: planes.pointer(at: 0)!,
                        bytesPerRow: (format.bytesPerRow.object(at: 0) as! Int))
        
        uTexture!.replace(region: MTLRegionMake2D(0, 0, Int(format.imageWidth) / 2, Int(format.imageHeight) / 2),
                          mipmapLevel: 0,
                          withBytes: planes.pointer(at: 1)!,
                          bytesPerRow: (format.bytesPerRow.object(at: 1) as! Int))
        
        vTexture!.replace(region: MTLRegionMake2D(0, 0, Int(format.imageWidth) / 2, Int(format.imageHeight) / 2),
                          mipmapLevel: 0,
                          withBytes: planes.pointer(at: 2)!,
                          bytesPerRow: (format.bytesPerRow.object(at: 2) as! Int))
        
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        commandEncoder?.setComputePipelineState(pipelineState)
        
        commandEncoder?.setTexture(yTexture, index: 0)
        commandEncoder?.setTexture(uTexture, index: 1)
        commandEncoder?.setTexture(vTexture, index: 2)
        commandEncoder?.setTexture(outTexture, index: 3)
        
        commandEncoder?.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder?.endEncoding()
        
        commandBuffer?.commit()
        
    }
}
