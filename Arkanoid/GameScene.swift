//
//  GameScene.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 23/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import SpriteKit
import GameplayKit

// MARK: Constants
let BallCategoryName = "ball"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "block"
let GameMessageName = "gameMessage"

let ballCategory: UInt32 = 0x1 << 0
let bottomCategory: UInt32 = 0x1 << 1
let blockCategory: UInt32 = 0x1 << 2
let paddleCategory: UInt32 = 0x1 << 3
let borderCategory: UInt32 = 0x1 << 4

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isFingerOnPaddle = false
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)
        ])
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.categoryBitMask = borderCategory
        self.physicsBody = borderBody
        
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        
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
        ball.physicsBody?.contactTestBitMask = bottomCategory | blockCategory
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let numberOfBlocks = 5
        let blockWidth: CGFloat = 65
        let blockHeight: CGFloat = 25
        let blockSize = CGSize(width: blockWidth, height: blockHeight)
        let totalBlockWidth = CGFloat(numberOfBlocks) * blockWidth
        let xOffset = (self.frame.width - totalBlockWidth) / 2
        
        //adding blocks programatically to the scene
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "brick_blue_small")
            
            block.position = CGPoint(x: (self.frame.width / 2) - 2 * xOffset - CGFloat(i) * blockWidth,
                                     y: (self.frame.height / 2) * 0.7)
            block.physicsBody = SKPhysicsBody(rectangleOf: blockSize)
            block.physicsBody?.allowsRotation = false
            block.physicsBody?.friction = 0.0
            block.physicsBody?.affectedByGravity = false
            block.physicsBody?.isDynamic = false
            block.name = BlockCategoryName
            block.physicsBody?.categoryBitMask = blockCategory
            block.zPosition = 2
            block.size = blockSize
            addChild(block)
            
            let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
            gameMessage.name = GameMessageName
            gameMessage.position = CGPoint(x: 0, y: 0)
            gameMessage.zPosition = 4
            gameMessage.setScale(0.0)
            addChild(gameMessage)
            
            gameState.enter(WaitingForTap.self)
        }
        
        
    }
    // MARK: Handling touch
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
    // MARK: Handling collisions
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
        
        // Adds SKEmitternode to destroyed blocks
        if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory {
            breakBlock(node: secondBody.node!)
        }
    }

    // MARK: Remove block from the scene
    func breakBlock(node: SKNode) {
        let particles: SKEmitterNode! = SKEmitterNode(fileNamed: "BrokenPlatform.sks")
        particles.position = node.position
        particles.zPosition = 3
        addChild(particles)
        particles?.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
                                          SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    // MARK: Generate random nuumber
    func randomFloat(from: CGFloat, to: CGFloat) -> CGFloat {
        let rand: CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) * from
    }
}




























