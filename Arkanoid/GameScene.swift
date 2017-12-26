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
    
    var numberOfLifes = 3
    var isFingerOnPaddle = false
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)
        ])
    var gameWon: Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                    SKAction.scale(to: 1.0, duration: 0.25)])
            gameOver.run(actionSequence)
            run(gameWon ? gameWonSound : gameOverSound)
        }
    }
    
    // MARK: Sounds
    let blipSound = SKAction.playSoundFileNamed("pongblip", waitForCompletion: false)
    let blipPaddleSound = SKAction.playSoundFileNamed("paddleBlip", waitForCompletion: false)
    let blockBreakSound = SKAction.playSoundFileNamed("block-break", waitForCompletion: false)
    let gameWonSound = SKAction.playSoundFileNamed("game-won", waitForCompletion: false)
    let gameOverSound = SKAction.playSoundFileNamed("game-over", waitForCompletion: false)
    
    // MARK: Hearts and blocks sizes
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        borderBody.categoryBitMask = borderCategory
        self.physicsBody = borderBody
        
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        paddle.physicsBody?.categoryBitMask = paddleCategory
        
        let bottomRect = CGRect(x: -self.frame.width / 2,
                                y: -(self.frame.height / 2),
                                width: self.frame.width * 2,
                                height: 10)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        bottom.zPosition = 5
        bottom.physicsBody?.categoryBitMask = bottomCategory
        addChild(bottom)
        
        let ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        ball.physicsBody?.mass = 0.005
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = bottomCategory | blockCategory | borderCategory | paddleCategory
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        let heart1 = childNode(withName: "heart1") as! SKSpriteNode
        let heart2 = childNode(withName: "heart2") as! SKSpriteNode
        let heart3 = childNode(withName: "heart3") as! SKSpriteNode
        
        let heartHeight: CGFloat = 33
        let heartWidth: CGFloat = 36
        let heartSize = CGSize(width: heartHeight, height: heartHeight)
        
        let blockHeight: CGFloat = 25
        let blockWidth: CGFloat = 65
        let blockSize: CGSize = CGSize(width: blockWidth, height: blockHeight)
    
        self.enumerateChildNodes(withName: "block", using: ({
            node, stop in
            if let block = node as? SKSpriteNode {
                block.physicsBody = SKPhysicsBody(rectangleOf: blockSize)
                block.physicsBody?.allowsRotation = false
                block.physicsBody?.friction = 0.0
                block.physicsBody?.affectedByGravity = false
                block.physicsBody?.isDynamic = false
                block.name = BlockCategoryName
                block.physicsBody?.categoryBitMask = blockCategory
                block.zPosition = 2
            }
        }))
        
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: 0, y: 0)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        self.addChild(gameMessage)
        
        self.gameState.enter(WaitingForTap.self)
        
        // adding emitter node to the ball (trail)
        let trailNode = SKNode()
        trailNode.zPosition = 1
        addChild(trailNode)
        let trail = SKEmitterNode(fileNamed: "BallTrail")!
        trail.targetNode = trailNode
        ball.addChild(trail)
    }
    
    // MARK: Handling touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState.currentState {
        case is WaitingForTap:
            gameState.enter(Playing.self)
            isFingerOnPaddle = true
        case is Playing:
            let touch = touches.first
            let touchLocation = touch?.location(in: self)
            
            if let body = physicsWorld.body(at: touchLocation!) {
                if body.node!.name == PaddleCategoryName {
                    isFingerOnPaddle = true
                }
            }
        case is GameOver:
            let newScene = GameScene(fileNamed: "GameScene")
            newScene?.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // add condition  "if isFingerOnPaddle" to make paddle move only when player touches the paddle
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        gameState.update(deltaTime: currentTime)
    }
    
    // MARK: Handling collisions
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            // if statement makes sure that first body is always the ball
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory {
                numberOfLifes -= 1
                print("Remaining lifes: \(numberOfLifes)")
                if numberOfLifes == 0 {
                    gameState.enter(GameOver.self)
                    gameWon = false
                } else {
                    gameState.enter(WaitingForTap.self)
                    //gameWon = false
                }
            }
            
            if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == borderCategory {
                run(blipSound)
            }
            
            if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory {
                run(blipPaddleSound)
            }
            
            // Adds SKEmitternode to destroyed blocks
            if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == blockCategory {
                breakBlock(node: secondBody.node!)
                if isGameWon() {
                    gameState.enter(GameOver.self)
                    gameWon = true
                }
            }
        }
    }
    
    // MARK: Remove block from the scene
    func breakBlock(node: SKNode) {
        run(blockBreakSound)
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
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodes(withName: BlockCategoryName, using: ({
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }))
        return numberOfBricks == 0
    }
    
    
}




























