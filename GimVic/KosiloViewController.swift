//
//  KosiloViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/20/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class KosiloViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var kosiloPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let selected = UserDefaults().string(forKey: UserSettings.lunch.rawValue) ?? ""
        if let index = ChooserData.sharedInstance.lunchTypes.index(of: selected) {
            kosiloPickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = ChooserData.sharedInstance.lunchTypes[row]
        UserDefaults().set(selected, forKey: UserSettings.lunch.rawValue)
    }
}
