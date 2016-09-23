//
//  SettingsViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SettingsViewController: UITableViewController, ChooserDataDelegate {
    @IBOutlet weak var showSubstitutionsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChooserData.sharedInstance.delegates[.settingsViewController] = self
        
        let showSubstitutions = UserDefaults().bool(forKey: UserSettings.showSubstitutions.rawValue)
        showSubstitutionsSwitch.setOn(showSubstitutions, animated: true)
        
        if !ChooserData.sharedInstance.isDataValid {
            ChooserData.sharedInstance.update()
        }
    }
    
    func refreshData(sender: AnyObject) {
        ChooserData.sharedInstance.update()
    }
    
    @IBAction func showSubstitutionsValueChanged(_ sender: AnyObject) {
        UserDefaults().set(showSubstitutionsSwitch.isOn,
                           forKey: UserSettings.showSubstitutions.rawValue)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        UserDefaults().synchronize()
        TimetableData.sharedInstance.update()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func chooserDataDidUpdateWithStatus(_ status: DataGetterStatus) {
        if !ChooserData.sharedInstance.isDataValid {
            var message: String?
            if status == .networkError {
                message = "Za prenos podatkov je potrebna internetna povezava."
            }
            
            let alertController = UIAlertController(title: "Napaka pri nalaganju podatkov.",
                                                    message: message,
                                                    preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Poskusi znova", style: .default, handler: {(action) in
                ChooserData.sharedInstance.update()
            })
            
            alertController.addAction(tryAgain)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
