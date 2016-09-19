//
//  GameScene.swift
//  SpriteKitIntro
//
//  Created by Dave Vo on 7/4/16.
//  Copyright (c) 2016 DaveVo. All rights reserved.
//

import SpriteKit
import AVFoundation

// Set these bits to be the same with the category mask in the physics definition
let wallMask: UInt32 = 0x1 << 0     // 1
let ballMask: UInt32 = 0x1 << 1     // 2
let pegMask: UInt32 = 0x1 << 2      // 4
let squareMask: UInt32 = 0x1 << 3   // 8
let orangePegMask: UInt32 = 0x1 << 4   // 16

class GameScene: SKScene {
    var myLabel: SKLabelNode!
    var cannon: SKSpriteNode!
    var block: SKSpriteNode!
    var bucket: SKSpriteNode!
    var background: SKAudioNode!
    var followCam: SKCameraNode!
    var nodeToFollow: SKNode!
    
    var touchLocation: CGPoint = CGPoint.zero
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        cannon = self.childNode(withName: "cannon_full") as! SKSpriteNode
        block = self.childNode(withName: "block") as! SKSpriteNode
        bucket = self.childNode(withName: "bucket") as! SKSpriteNode
        followCam = self.childNode(withName: "camera") as! SKCameraNode
        
        self.physicsWorld.contactDelegate = self
        
        let rads = -CGFloat(M_PI / 2.0)
        let action = SKAction.rotate(byAngle: rads, duration: 1)
        block.run(SKAction.repeatForever(action))
        
        let rightMove = SKAction.moveBy(x: 840.0, y: 0.0, duration: 2)
        rightMove.timingMode = .easeInEaseOut
        let leftMove = SKAction.moveBy(x: -840.0, y: 0.0, duration: 2)
        leftMove.timingMode = .easeInEaseOut
        let seq = SKAction.sequence([rightMove, leftMove])
        bucket.run(SKAction.repeatForever(seq))
        
        // Set the background audio, why crash?
        //background = SKAudioNode(fileNamed: "bg.mp3")
        //self.addChild(background)
        
        // Preload the audio
        do {
            let sounds = ["cannon", "hit"]
            for sound in sounds {
                let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "wav")!))
                player.prepareToPlay()
            }
        } catch {
            print("error when loading audio")
        }
        
        // Setup the label
        myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Ready"
        myLabel.fontSize = 72
        myLabel.fontColor = UIColor.red
        myLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(myLabel)
        
        // Setup the boundary
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsBody?.categoryBitMask = wallMask
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        touchLocation = touches.first!.location(in: self)
        myLabel.removeFromParent()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = touches.first!.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let ball: SKSpriteNode = SKScene(fileNamed: "Ball")!.childNode(withName: "ball") as! SKSpriteNode
        ball.removeFromParent()
        self.addChild(ball)
        ball.zPosition = 0
        ball.position = cannon.position
        let angleInRadians = Float(cannon.zRotation)
        let speed = CGFloat(100.0)
        let vx = CGFloat(cosf(angleInRadians)) * speed
        let vy = CGFloat(sinf(angleInRadians)) * speed
        ball.physicsBody?.applyImpulse(CGVector(dx: vx, dy: vy))
        // enable the ball to be collide with all but the square
        ball.physicsBody?.collisionBitMask = wallMask | ballMask | pegMask | orangePegMask
        // enable the notification if the ball contacts anything, including the square
        ball.physicsBody?.contactTestBitMask = ball.physicsBody!.collisionBitMask | squareMask
        self.run(SKAction.playSoundFileNamed("cannon.wav", waitForCompletion: true))
        
        // Remove the sound when game starts
        //background.runAction(SKAction.stop())
        
        nodeToFollow = ball
        followCam.run(SKAction.scale(to: 0.75, duration: 0.5))
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let percent = touchLocation.x / size.width
        let newAngle = percent * 180 - 180
        cannon.zRotation = CGFloat(newAngle) * CGFloat(M_PI) / 180.0
        
        if nodeToFollow != nil {
            followCam.position = nodeToFollow.position
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if (other.categoryBitMask == pegMask || other.categoryBitMask == orangePegMask) {
            print("hit peg")
            didHitPeg(other)
        } else if (other.categoryBitMask == orangePegMask) {
            print("hit orange peg")
        } else if (other.categoryBitMask == wallMask) {
            print("hit wall")
        } else if (other.categoryBitMask == squareMask) {
            print("hit square")
        } else if (other.categoryBitMask == ballMask) {
            print("hit ball")
        }
    }
    
    func didHitPeg(_ peg: SKPhysicsBody) {
        let blue = UIColor(red: 0.16, green: 0.73, blue: 0.78, alpha: 1.0)
        let orange = UIColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        let spark = SKEmitterNode(fileNamed: "SparkParticle")!
        spark.position = peg.node!.position
        spark.particleColor = (peg.categoryBitMask == orangePegMask) ? orange : blue
        self.addChild(spark)
        peg.node!.removeFromParent()
        
        self.run(SKAction.playSoundFileNamed("hit.wav", waitForCompletion: true))
    }
}
