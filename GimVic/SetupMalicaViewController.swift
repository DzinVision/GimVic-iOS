//
//  SetupMalicaViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SetupMalicaViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var malicaPickerView: UIPickerView!

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ChooserData.sharedInstance.snackTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString? {
        let title = ChooserData.sharedInstance.snackTypes[row]
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "nextSegue" {
                let selected = ChooserData.sharedInstance.snackTypes[malicaPickerView.selectedRow(inComponent: 0)]
                UserDefaults().set(selected, forKey: UserSettings.snack.rawValue)
            }
        }
    }
}
