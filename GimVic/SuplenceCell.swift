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
    
    func setOpombaHidden(_ hidden: Bool) {
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
