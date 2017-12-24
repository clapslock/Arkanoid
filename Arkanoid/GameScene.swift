//
//  GameScene.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 23/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import SpriteKit

let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let ballCategory: UInt32 = 0x1 << 0
let bottomCategory: UInt32 = 0x1 << 1
let blockCategory: UInt32 = 0x1 << 2
let paddleCategory: UInt32 = 0x1 << 3
let borderCategory: UInt32 = 0x1 << 4

let blockWidth = 77
let blockHeight = 33



class GameScene: SKScene, SKPhysicsContactDelegate {
   
    var isFingerOnPaddle = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.categoryBitMask = borderCategory
        self.physicsBody = borderBody
        
        let paddle = SKSpriteNode(imageNamed: "paddle_blue")
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.allowsRotation = false
        paddle.physicsBody?.angularDamping = 0
        paddle.physicsBody?.angularVelocity = 0
        paddle.position.y = (-self.frame.height / 2) + 20
        paddle.zPosition = 5
        
        //let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        paddle.physicsBody?.categoryBitMask = paddleCategory
        addChild(paddle)


        let bottomRect = CGRect(x: 0,
                                y: -(self.frame.height / 2),
                                width: self.frame.width,
                                height: 6)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        bottom.zPosition = 9
        bottom.physicsBody?.categoryBitMask = bottomCategory
        addChild(bottom)
        
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = bottomCategory
        ball.physicsBody!.applyImpulse(CGVector(dx: 1, dy: -12))

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node!.name == PaddleCategoryName {
                isFingerOnPaddle = true
            }
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            if paddleX < 0 {
                paddleX = max(paddleX, -(self.frame.size.width / 2) + (paddle.size.width / 2))
            } else if paddleX > 0 {
                paddleX = min(paddleX, (self.frame.size.width / 2) - (paddle.size.width / 2))
                
            }
            
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
            print("Colision works!")
        }
        
    }
}




























