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
    var fullHeart: SKTexture = SKTexture(imageNamed: "full_heart")
    var emptyHeart: SKTexture = SKTexture(imageNamed: "empty_heart")
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
            var gameSceneName: String!
            if isGameWon() {
                gameSceneName = nextSceneName(scene!.name!)
            } else if !isGameWon() {
                gameSceneName = scene!.name!
            }
            
            let newScene = GameScene(fileNamed: gameSceneName)
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
        
        let heart1 = childNode(withName: "heart1") as! SKSpriteNode
        let heart2 = childNode(withName: "heart2") as! SKSpriteNode
        let heart3 = childNode(withName: "heart3") as! SKSpriteNode
        
        let nextLevelBtn = SKSpriteNode(imageNamed: "next")
        nextLevelBtn.setScale(CGFloat(0.25))
        nextLevelBtn.position = CGPoint(x: 0, y: -100)
        nextLevelBtn.zPosition = 5
        
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
                switch numberOfLifes {
                case 2:
                    heart1.texture = emptyHeart
                case 1:
                    heart2.texture = emptyHeart
                default:
                    break
                }
                if numberOfLifes == 0 {
                    heart3.texture = emptyHeart
                    gameState.enter(GameOver.self)
                    gameWon = false
                } else {
                    gameState.enter(WaitingForTap.self)
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
                let secondBodyTexture = (secondBody.node as? SKSpriteNode)?.texture?.name
                
                if brickIsCracked(secondBodyTexture!) {
                    breakBlock(node: secondBody.node!)
                } else {
                    (secondBody.node as? SKSpriteNode)?.texture = SKTexture(imageNamed: crackedShell(secondBodyTexture!))
                }
                
                if isGameWon() {
                    addChild(nextLevelBtn)
                    let actionSequence = SKAction.sequence([SKAction.scale(to: 1.0, duration: 0.25)])
                    nextLevelBtn.run(actionSequence)
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
    
    func nextSceneName(_ name: String) -> String {
        switch name {
        case "Level1":
            return "Level2"
        case "Level2":
            return "Level3"
        case "Level3":
            return "Level4"
        case "Level4":
            return "Level5"
        case "Level5":
            return "Level6"
        case "Level6":
            return "Level7"
        default:
            return ""
        }
    }
    
    func brickIsCracked(_ texture: String) -> Bool{
        switch texture {
        case "brick_blue_small_cracked",
             "brick_green_small_cracked",
             "brick_yellow_small_cracked",
             "brick_pink_small_cracked",
             "brick_violet_small_cracked":
            return true
             //"brick_blue_small",
        case "brick_green_small",
             "brick_yellow_small":
             //"brick_pink_small":
             //"brick_violet_small":
            return false
        default:
            return true
        }
    }
    
    func crackedShell(_ texture: String) -> String {
        switch texture {
// Uncomment to make all bricks 2-hit to destroy
//        case "brick_blue_small":
//            return "brick_blue_small_cracked"
//
//        case "brick_pink_small":
//            return "brick_pink_small_cracked"
            
        case "brick_green_small":
            return "brick_green_small_cracked"
            
        case "brick_yellow_small":
            return "brick_yellow_small_cracked"
            
//        case "brick_violet_small":
//            return "brick_violet_small_cracked"
        default:
            return "No souch texture exists"
        }
        
        
    }
}

extension SKTexture
{
    var name : String
    {
        return self.description.slice(start: "'",to: "'")!
    }
}

extension String {
    func slice(start: String, to: String) -> String?
    {
        
        return (range(of: start)?.upperBound).flatMap
            {
                sInd in
                (range(of: to, range: sInd..<endIndex)?.lowerBound).map
                    {
                        eInd in
                        substring(with:sInd..<eInd)
                        
                }
        }
    }
}




























