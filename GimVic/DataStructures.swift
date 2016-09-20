//
//  DataStructures.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import Foundation

enum UserSettings: String {
    case lastOpened = "last_opened"
    case lastRefreshedChooserData = "last_refreshed_chooser_data"
    case showSubstitutions = "show_substitutions"
    case profesorFilter = "profesor_filter"
    case filter = "filter"
    case maturitetniPredmeti = "maturitetni_predmeti"
    case izbirniPredmeti = "izbirni_predmeti"
    case snack = "snack"
    case lunch = "lunch"
}

enum Weekdays: String {
    case monday = "Ponedeljek"
    case tuesday = "Torek"
    case wednesday = "Sreda"
    case thursday = "Četrtek"
    case friday = "Petek"
    
    init?(index: Int) {
        switch index {
        case 0:
            self = .monday
        case 1:
            self = .tuesday
        case 2:
            self = .wednesday
        case 3:
            self = .thursday
        case 4:
            self = .friday
        default:
            return nil
        }
    }
}
