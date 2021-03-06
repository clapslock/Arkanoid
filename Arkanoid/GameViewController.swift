//
//  GameViewController.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 23/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var selectedLevel: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let scene = GameScene(fileNamed:selectedLevel) {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFit
            
            
            skView.presentScene(scene)
        }
    }
    
    @IBAction func goBackToSelectLevel(_ sender: UIButton) {
        performSegue(withIdentifier: "LevelSelectVC", sender: self)
    }
    
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func returnToLevelSelect() {
        dismiss(animated: true, completion: nil)
    }
}
