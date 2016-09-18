//
//  ViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/18/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class SuplenceViewController: UIViewController {
    @IBOutlet weak var testLabel: UILabel!
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testLabel.text = "\(index)"
    }
}

