//
//  SuplenceCell.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class SuplenceCell: UITableViewCell {

    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var classroomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var opombaTitleLabel: UILabel!
    @IBOutlet weak var opombaLabel: UILabel!
    @IBOutlet weak var stackViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setNote(_ note: String?) {
        guard let note = note else {
            setNoteHidden(true)
            return
        }
        
        setNoteHidden(false)
        opombaLabel.text = note
    }
    
    func isSubstitution(_ substitution: Bool) {
        let color: UIColor
        if !substitution {
            color = UIColor.white
        } else {
            color = UIColor(red: 255/255.0, green: 51/255.0, blue: 43/255.0, alpha: 1.0)
        }
        
        hourLabel.textColor = color
        lessonLabel.textColor = color
        classroomLabel.textColor = color
        teacherLabel.textColor = color
        opombaTitleLabel.textColor = color
        opombaLabel.textColor = color
    }
    
    func setNoteHidden(_ hidden: Bool) {
        if hidden {
            stackViewConstraint.constant = 0
            opombaTitleLabel.isHidden = true
            opombaLabel.isHidden = true
        } else {
            stackViewConstraint.constant = 8
            opombaTitleLabel.isHidden = false
            opombaLabel.isHidden = false
        }
    }
}
