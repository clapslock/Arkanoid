//
//  Playing.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 23/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import SpriteKit
import GameplayKit

class Playing: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }
    
}
