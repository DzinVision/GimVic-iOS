//
//  SettingsViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var showSubstitutionsSwitch: UISwitch!
    
    @IBAction func showSubstitutionsValueChanged(_ sender: AnyObject) {
        print(showSubstitutionsSwitch.isOn)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
