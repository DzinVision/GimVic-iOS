//
//  SetupFilterViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SetupFilterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var profesorFilter = false
    var filter = ""
    let animationDuration = 0.2
    
    @IBOutlet weak var showSubstitutionsSwitch: UISwitch!
    @IBOutlet weak var filterTypeControl: UISegmentedControl!
    @IBOutlet weak var filterPickerView: UIPickerView!
    @IBOutlet weak var additionalClassesButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAdditionalClassesButton(false)
    }
    
    func configureAdditionalClassesButton(_ animated: Bool) {
        if filter == "" {
            additionalClassesButton.alpha = 0.0
            additionalClassesButton.isHidden = true
            return
        }
        
        let classNumber = Int(filter.substring(to: filter.index(after: filter.startIndex))) ?? 0
        
        if classNumber < 3 {
            if animated {
                UIView.animate(withDuration: animationDuration,
                               animations: {
                                self.additionalClassesButton.alpha = 0.0
                    }, completion: {completition in
                        self.additionalClassesButton.isHidden = true
                })
            } else {
                additionalClassesButton.alpha = 0.0
                additionalClassesButton.isHidden = true
            }
        } else {
            if animated {
                self.additionalClassesButton.isHidden = false
                UIView.animate(withDuration: animationDuration,
                               animations: {
                                self.additionalClassesButton.alpha = 1.0
                })
            } else {
                additionalClassesButton.alpha = 1.0
                additionalClassesButton.isHidden = false
            }
        }
        
        if classNumber == 3 {
            additionalClassesButton.setTitle("Nastavi izbirne predmete", for: .normal)
        } else if classNumber == 4 {
            additionalClassesButton.setTitle("Nastavi maturitetne predmete", for: .normal)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if profesorFilter {
            return ChooserData.sharedInstance.teachers.count
        }
        return ChooserData.sharedInstance.mainClasses.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    attributedTitleForRow row: Int,
                    forComponent component: Int) -> NSAttributedString? {
        let title: String
        if profesorFilter {
            title = ChooserData.sharedInstance.teachers[row]
        } else {
            title = ChooserData.sharedInstance.mainClasses[row]
        }
        
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if profesorFilter {
            filter = ChooserData.sharedInstance.teachers[row]
        } else {
            filter = ChooserData.sharedInstance.mainClasses[row]
        }
        
        configureAdditionalClassesButton(true)
    }
    
    @IBAction func filterTypeChanged(_ sender: AnyObject) {
        let selectedSegment = filterTypeControl.selectedSegmentIndex
        if selectedSegment == 0 {
            profesorFilter = false
        } else {
            profesorFilter = true
        }
        
        filterPickerView.reloadAllComponents()
        
        if profesorFilter {
            filter = ChooserData.sharedInstance.teachers[filterPickerView.selectedRow(inComponent: 0)]
        } else {
            filter = ChooserData.sharedInstance.mainClasses[filterPickerView.selectedRow(inComponent: 0)]
        }
        
        configureAdditionalClassesButton(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "AdditionalClassesSegue" {
                if let viewController = segue.destination as? AdditionalClassesViewController {
                    viewController.filter = filter
                }
            }
            
            if identifier == "nextSegue" {
                UserDefaults().set(showSubstitutionsSwitch.isOn, forKey: UserSettings.showSubstitutions.rawValue)
                UserDefaults().set(profesorFilter, forKey: UserSettings.profesorFilter.rawValue)
                
                if profesorFilter {
                    filter = ChooserData.sharedInstance.teachers[filterPickerView.selectedRow(inComponent: 0)]
                } else {
                    filter = ChooserData.sharedInstance.mainClasses[filterPickerView.selectedRow(inComponent: 0)]
                }
                UserDefaults().set(filter, forKey: UserSettings.filter.rawValue)
            }
        }
    }
    
}
