//
//  ViewController.swift
//  testMtlTexture
//
//  Created by Roberto Perez Cubero on 26/09/2017.
//  Copyright © 2017 tokbox. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import OpenTok

// room: 0==0
let kApiKey = "45328772"
let kToken = "T1==cGFydG5lcl9pZD00NTMyODc3MiZzaWc9M2NjODJlYzJmMTQyMmI1Mzc1YWEzN2VlODAxYjI3Y2I2MzY0OTlhZTpzZXNzaW9uX2lkPTJfTVg0ME5UTXlPRGMzTW41LU1UVXdOalF6TXpjMk1EUTNNSDVwY21Wa2F6Um1lbkp2T1d4WU5UZERXa2R5U0RkbllUUi1mZyZjcmVhdGVfdGltZT0xNTA2NDMzNzYwJm5vbmNlPTAuNjU3NzY1MzQ1NDE1MTAwNSZyb2xlPXB1Ymxpc2hlciZleHBpcmVfdGltZT0xNTA2NTIwMTYwJmNvbm5lY3Rpb25fZGF0YT0lN0IlMjJ1c2VyTmFtZSUyMiUzQSUyMkFub255bW91cyUyMFVzZXIxMzQ2JTIyJTdEJmluaXRpYWxfbGF5b3V0X2NsYXNzX2xpc3Q9"
let kSessionId = "2_MX40NTMyODc3Mn5-MTUwNjQzMzc2MDQ3MH5pcmVkazRmenJvOWxYNTdDWkdySDdnYTR-fg"


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
        
    //var textureData = [Float](repeatElement(0, count: 2000))
    var session : OTSession?
    let sessionDelegate = SessionDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: sessionDelegate)
        session?.connect(withToken: kToken, error: nil)
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let node = scene.rootNode.childNode(withName: "plane", recursively: false)!
        //node.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 1)))
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // ==
        
        /*
        for i in 0..<textureData.count {
            textureData[i] = Float(arc4random_uniform(200)) / Float(arc4random_uniform(200))
        }
        textureData.withUnsafeBytes { (data)  in
            text?.replace(region: MTLRegionMake2D(0, 0, 100, 100), mipmapLevel: 0, withBytes: data.baseAddress!, bytesPerRow: 200)
        }*/
        
        sessionDelegate.node = node
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

class SessionDelegate: NSObject, OTSessionDelegate {
    var node: SCNNode?
    
    func sessionDidConnect(_ session: OTSession) {
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        let s = OTSubscriber(stream: stream, delegate: nil)
        s?.videoRender = ARVideoRender(node!)
        session.subscribe(s!, error: nil)        
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        
    }
}

