//
//  ViewController.swift
//  Module 2.12(2)
//
//  Created by Александр Останин on 03.05.2020.
//  Copyright © 2020 Yuri Prishchepov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let missleCategory = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
    static let otherCategory = CollisionCategory(rawValue: 1 << 2)
}

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sceneView.delegate = self
        
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        sceneView.session.pause()
    }
    
    func getTargetPosition () -> CGRect {
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            if let error = error {
                print("Failed to detect faces: \(error)")
                return
            }
            request.results?.forEach({ (res) in
                DispatchQueue.main.async {
                    guard let faceObservations = res as? VNFaceObservation else { return }
                    let target = faceObservations.boundingBox
                    
                }
            })
            
        }
        
    }
    
    
    
//    fileprivate func draw (faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
//        CATransaction.begin()
//        for observation in faces {
////            let faceBox = boundingBox()
////            let faceLayer = shapeLayer()
//        }
//    }
//
//    fileprivate func handleDetectedFaces (request: VNRequest?, error: Error?) {
//        if let nsError = error as NSError? {
//            print("Face detection error: \(nsError)")
//            return
//        }
//        DispatchQueue.main.async {
////            guard let drawLayer = self.pathLayer
//            guard let results = request?.results as? [VNFaceObservation] else {
//                return
//            }
////            self.draw()
////            drawLayer().
//        }
//    }
//
//    fileprivate func handleDetectedFaceLandarks (request: VNRequest?, error: Error?) {
//        if let nsError = error as NSError? {
//            print("Face landmark detection error: \(nsError)")
//            return
//        }
//    }
//
//    let landmarkLayer = CAShapeLayer()
//    let landmarkPath =  CGMutablePath()
    
    
    func createMissle() -> SCNNode {
        var node = SCNNode()
        
        let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/Technosphere.OBJ")
        node = (scene?.rootNode.childNode(withName: "Technosphere", recursively: true)!)!
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        node.name = "ball"
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        
        node.physicsBody?.categoryBitMask = CollisionCategory.missleCategory.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.targetCategory.rawValue
        
        return node
    }
    
    func fireMissle () {
        var node = SCNNode()
        
        node = createMissle()
        
        let direction = self.getTargetPosition()
    }

    @IBAction func shotButton(_ sender: Any) {
        
    }
    
}

extension ViewController: ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.targetCategory.rawValue {
            let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil)
            contact.nodeB.addParticleSystem(explosion!)
            
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
//                can add score lable
            }
        }
    }
}
