//
//  SetupKosiloViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SetupKosiloViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var kosiloPickerView: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ChooserData.sharedInstance.lunchTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ChooserData.sharedInstance.lunchTypes[row]
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    @IBAction func endButtonPressed(_ sender: AnyObject) {
        let selected = ChooserData.sharedInstance.lunchTypes[kosiloPickerView.selectedRow(inComponent: 0)]
        UserDefaults().set(selected, forKey: UserSettings.lunch.rawValue)
        UserDefaults().synchronize()
        
        TimetableData.sharedInstance.update()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
