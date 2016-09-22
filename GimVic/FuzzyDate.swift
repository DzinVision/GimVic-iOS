//
//  FuzzyDate.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/22/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import Foundation

struct FuzzyDate {
    static func timeSince(_ date: Date) -> String {
        let timeInterval = Date().timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        if minutes < 60 {
            return "\(minutes)min"
        }
        
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h"
        }
        
        let days = hours / 24
        if days == 1 {
            return "1 dan"
        }
        
        return "\(days)dni"
    }
}
