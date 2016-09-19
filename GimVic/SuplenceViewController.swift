//
//  ViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/18/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class SuplenceViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var snackLabel: UILabel!
    @IBOutlet weak var lunchLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = Weekdays(index: index)!.rawValue
        
        snackLabel.text = "koruzna bombeta (velika), tunin namaz, jabolcni zavitek, sok"
        lunchLabel.text = "piscancji raznic, prazen krompir, pecena zelenjava, voda ali sok"
        
        tableView.register(UINib(nibName: "SuplenceCell", bundle: nil), forCellReuseIdentifier: "SuplenceCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuplenceCell", for: indexPath) as! SuplenceCell
        return cell
    }
}

