//
//  AdditionalClassesViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/20/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class AdditionalClassesViewController: UITableViewController {
    var classNumber = 0
    var data = [String]()
    var filter = ""
    var selected = [String]()
    var key = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filter = UserDefaults().string(forKey: UserSettings.filter.rawValue) ?? ""
        
        classNumber = Int(filter.substring(to: filter.index(after: filter.startIndex))) ?? 0
        
        if classNumber == 3 {
            navigationItem.title = "Izbirni Predmeti"
            key = UserSettings.izbirniPredmeti.rawValue
        } else if classNumber == 4 {
            navigationItem.title = "Maturitetni Predmeti"
            key = UserSettings.maturitetniPredmeti.rawValue
        }
        
        selected = (UserDefaults().array(forKey: key) as? [String]) ?? []
        
        populateData()
    }
    
    func populateData() {
        let filter: String
        if classNumber == 3 {
            filter = "3"
        } else {
            filter = "M"
        }
        
        for predmet in ChooserData.sharedInstance.additionalClasses {
            if predmet.substring(to: predmet.index(after: predmet.startIndex)) == filter {
                data.append(predmet)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdditionalClassesCell", for: indexPath)

        let predmet = data[indexPath.row]
        if selected.contains(predmet) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = predmet

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let predmet = data[indexPath.row]
        
        if cell.accessoryType == .none {
            cell.accessoryType = .checkmark
            selected.append(predmet)
        } else {
            cell.accessoryType = .none
            if let index = selected.index(of: predmet) {
                selected.remove(at: index)
            }
        }
        
        UserDefaults().set(selected, forKey: key)
    }
}
