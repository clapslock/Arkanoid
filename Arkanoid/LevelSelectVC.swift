//
//  LevelSelectVC.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 25/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import UIKit

class LevelSelectVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "MenuVC", sender: self)
    }
    
    
    @IBAction func unwindToLevelSelect(segue: UIStoryboardSegue) {
        print("It worked!\nBack in level select again!")
        if let gameVC = segue.source as? GameViewController {
            
        }
        
        
    }

}