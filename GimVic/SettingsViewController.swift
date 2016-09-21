//
//  SettingsViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

protocol UpdatableSettings {
    func update()
}

class SettingsViewController: UITableViewController, ChooserDataDelegate {
    @IBOutlet weak var showSubstitutionsSwitch: UISwitch!
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChooserData.sharedInstance.delegates[.settingsViewController] = self
        
        let showSubstitutions = UserDefaults().bool(forKey: UserSettings.showSubstitutions.rawValue)
        showSubstitutionsSwitch.setOn(showSubstitutions, animated: true)
        
        refresher.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
//        tableView.addSubview(refresher)
    }
    
    func refreshData(sender: AnyObject) {
        updateChooserData()
    }
    
    func updateChooserData() {
        ChooserData.sharedInstance.update()
        UserDefaults().set(Date(), forKey: UserSettings.lastRefreshedChooserData.rawValue)
    }
    
    @IBAction func showSubstitutionsValueChanged(_ sender: AnyObject) {
        UserDefaults().set(showSubstitutionsSwitch.isOn,
                           forKey: UserSettings.showSubstitutions.rawValue)
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        UserDefaults().synchronize()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func chooserDataDidUpdateWithStatus(_ status: ChooserDataStatus) {
        refresher.endRefreshing()
        if !ChooserData.sharedInstance.isDataValid {
            var message: String?
            if status == .networkError {
                message = "Za prenos podatkov je potrebna internetna povezava."
            }
            
            let alertController = UIAlertController(title: "Napaka pri nalaganju podatkov.",
                                                    message: message,
                                                    preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Poskusi znova", style: .default, handler: {(action) in
                self.updateChooserData()
            })
//            let cancel = UIAlertAction(title: "Vredu", style: .cancel, handler: nil)
//            alertController.addAction(cancel)
            alertController.addAction(tryAgain)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
