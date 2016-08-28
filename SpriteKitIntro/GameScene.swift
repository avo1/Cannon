//
//  GameScene.swift
//  SpriteKitIntro
//
//  Created by Dave Vo on 7/4/16.
//  Copyright (c) 2016 DaveVo. All rights reserved.
//

import SpriteKit

let wallMask: UInt32 = 0x1 << 0     // 1
let ballMask: UInt32 = 0x1 << 1     // 2
let pegMask: UInt32 = 0x1 << 2      // 4
let squareMask: UInt32 = 0x1 << 3   // 8

class GameScene: SKScene {
    var myLabel: SKLabelNode!
    var cannon: SKSpriteNode!
    var touchLocation: CGPoint = CGPointZero
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        cannon = self.childNodeWithName("cannon_full") as! SKSpriteNode
        self.physicsWorld.contactDelegate = self
        
        // Setup the label
        myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel.text = "Ready"
        myLabel.fontSize = 72
        myLabel.fontColor = UIColor.redColor()
        myLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(myLabel)
        
        // Setup the boundary
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        physicsBody?.categoryBitMask = wallMask
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        touchLocation = touches.first!.locationInNode(self)
        myLabel.removeFromParent()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchLocation = touches.first!.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let ball: SKSpriteNode = SKScene(fileNamed: "Ball")!.childNodeWithName("ball") as! SKSpriteNode
        ball.removeFromParent()
        self.addChild(ball)
        ball.zPosition = 0
        ball.position = cannon.position
        let angleInRadians = Float(cannon.zRotation)
        let speed = CGFloat(100.0)
        let vx = CGFloat(cosf(angleInRadians)) * speed
        let vy = CGFloat(sinf(angleInRadians)) * speed
        ball.physicsBody?.applyImpulse(CGVectorMake(vx, vy))
        ball.physicsBody?.collisionBitMask = wallMask | ballMask | pegMask
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let percent = touchLocation.x / size.width
        let newAngle = percent * 180 - 180
        cannon.zRotation = CGFloat(newAngle) * CGFloat(M_PI) / 180.0
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBeginContact(contact: SKPhysicsContact) {
        print("booom")
    }
}
