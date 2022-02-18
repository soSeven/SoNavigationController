//
//  ViewController.swift
//  SoNavigationController
//
//  Created by soSeven on 02/18/2022.
//  Copyright (c) 2022 soSeven. All rights reserved.
//

import UIKit
import SoNavigationController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        so.barConfiguration.backgroundColor = .white
        so.barConfiguration.backgroundImage = ImageIdentifier(image: UIImage(), identifier: "")
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

