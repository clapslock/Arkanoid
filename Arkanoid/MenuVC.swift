//
//  MenuVC.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 25/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    @IBAction func playBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func settingsBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func creditsBtnPressed(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        if let levelSelectVC = segue.source as? LevelSelectVC {
            
        }
    }
}
