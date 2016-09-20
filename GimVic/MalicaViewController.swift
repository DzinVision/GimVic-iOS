//
//  MalicaViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/20/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class MalicaViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var malicaPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let selected = UserDefaults().string(forKey: UserSettings.snack.rawValue) ?? ""
        if let index = ChooserData.sharedInstance.snackTypes.index(of: selected) {
            malicaPickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ChooserData.sharedInstance.snackTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ChooserData.sharedInstance.snackTypes[row]
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = ChooserData.sharedInstance.snackTypes[row]
        UserDefaults().set(selected, forKey: UserSettings.snack.rawValue)
    }
}
