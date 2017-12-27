//
//  SettingsVC.swift
//  Arkanoid
//
//  Created by Bartosz Kunat on 27/12/2017.
//  Copyright © 2017 Clapslock Interactive. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var paddleImage: UIImageView!
    @IBOutlet weak var ballImage: UIImageView!
    @IBOutlet weak var paddleSlider: UISlider!
    @IBOutlet weak var ballSlider: UISlider!
    
    @IBAction func paddleSlider(_ sender: UISlider) {
        sender.setValue(Float(lroundf(paddleSlider.value)), animated: true)
        paddleImage.image = UIImage(named: selectedPaddle(Int(paddleSlider.value)))
    }
    
    @IBAction func ballSlider(_ sender: UISlider) {
        sender.setValue(Float(lroundf(ballSlider.value)), animated: true)
        ballImage.image = UIImage(named: selectedBall(Int(ballSlider.value)))
    }
    
    func selectedBall(_ sliderValue: Int) -> String {
        switch sliderValue {
        case 0:
            return "orange_ball"
        case 1:
            return "blue_ball"
        case 2:
            return "green_ball"
        case 3:
            return "red_ball"
        case 4:
            return "silver_ball"
        case 5:
            return "yellow_ball"
        default:
            return "orange_ball"
        }
    }
    
    func selectedPaddle(_ sliderValue: Int) -> String {
        switch sliderValue {
        case 0:
            return "paddle_black"
        case 1:
            return "paddle_blue"
        case 2:
            return "paddle_orange"
        case 3:
            return "paddle_pink"
        case 4:
            return "paddle_yellow"
        default:
            return "paddle_black"
        }
    }
    
}
