//
//  ViewController.swift
//  ExampleMixingPlayer
//
//  Created by Arveen kumar on 7/9/20.
//  Copyright © 2020 Feed FM. All rights reserved.
//

import UIKit
import FeedMedia

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let myPlayer:ExampleMixingPlayer = ExampleMixingPlayer()
        let feedPlayer = FMAudioPlayer.shared()
        feedPlayer.whenAvailable({
            
            feedPlayer.setPlayerControlDelegate(myPlayer)
            feedPlayer.prepareToPlay()
            
        }) {
            
        }
    }


}

