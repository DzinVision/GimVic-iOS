//
//  ViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/18/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SuplenceViewController: UIViewController, UITableViewDataSource, TimetableDataDelegate {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var snackLabel: UILabel!
    @IBOutlet weak var lunchLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    let refreshControl = UIRefreshControl()
    var profesor = false
    
    var data: TimetableEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateLabel.text = Weekdays(index: index)!.rawValue
        
        TimetableData.sharedInstance.delegates[TimetableData.DelegateID(rawValue: index)!] = self
        data = TimetableData.sharedInstance.timetableEntryFor(TimetableData.Weekday(rawValue: index)!)
        setJedilnik()
        profesor = UserDefaults().bool(forKey: UserSettings.profesorFilter.rawValue)
        
        tableView.register(UINib(nibName: "SuplenceCell", bundle: nil), forCellReuseIdentifier: "SuplenceCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.tintColor = UIColor.white
        refreshControl.tintColorDidChange()
        tableView.addSubview(refreshControl)
    }
    
    func setJedilnik() {
        snackLabel.text = data?.snack ?? ""
        lunchLabel.text = data?.lunch ?? ""
    }
    
    func refresh(sender: AnyObject) {
        let viewControllers = RootViewController.sharedInstance?.suplenceViewControllers ?? []
        for viewController in viewControllers {
            if viewController.index == index {
                continue
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                viewController.tableView.contentOffset.y = -viewController.refreshControl.frame.size.height
                }, completion: {finished in
                    viewController.refreshControl.beginRefreshing()
            })
        }
        
        TimetableData.sharedInstance.update()
    }
    
    // MARK: - Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.lessons.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuplenceCell", for: indexPath) as! SuplenceCell
        
        let lesson = data!.lessons[indexPath.row]
        cell.hourLabel.text = String(lesson.hour)
        cell.lessonLabel.text = lesson.subjects.first
        cell.classroomLabel.text = lesson.classrooms.first
        if profesor {
            cell.teacherLabel.text = lesson.classes.first
        } else {
            cell.teacherLabel.text = lesson.teachers.first
        }
        
        cell.setNote(lesson.note)
        cell.isSubstitution(lesson.substitution)
        
        return cell
    }
    
    // MARK: - Timetable Data Delegate
    func timetableDataDidUpdateWithStatus(_ status: DataGetterStatus) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            self.tableView.contentOffset.y = 0
            }, completion: {finished in
                self.refreshControl.endRefreshing()
        })
        
        if status == .success {
            data = TimetableData.sharedInstance.timetableEntryFor(TimetableData.Weekday(rawValue: index)!)
            tableView.reloadData()
            setJedilnik()
            profesor = UserDefaults().bool(forKey: UserSettings.profesorFilter.rawValue)
        }
    }
}

