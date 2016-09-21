//
//  DataStructures.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import Foundation

public enum DataGetterStatus {
    case success, networkError, error
}

public struct Lesson {
    public var hour = 0
    public var classes = [String]()
    public var classrooms = [String]()
    public var subjects = [String]()
    public var teachers = [String]()
    public var substitution = false
    public var note: String? = nil
    
    init(dictionary: [String: Any]) {
        hour = (dictionary["hour"] as? Int) ?? 0
        classes = (dictionary["classes"] as? [String]) ?? []
        classrooms = (dictionary["classrooms"] as? [String]) ?? []
        subjects = (dictionary["subjects"] as? [String]) ?? []
        teachers = (dictionary["teachers"] as? [String]) ?? []
        substitution = (dictionary["substitution"] as? Bool) ?? false
        note = dictionary["note"] as? String
    }
    
    init() {}
    
    var dictionaryValue: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["hour"] = hour
        dictionary["classes"] = classes
        dictionary["classrooms"] = classrooms
        dictionary["subjects"] = subjects
        dictionary["teachers"] = teachers
        dictionary["substitution"] = substitution
        dictionary["note"] = note
        
        return dictionary
    }
}

public struct TimetableEntry {
    public var lessons = [Lesson]()
    public var lunch = ""
    public var snack = ""
    public var weekday = TimetableData.Weekday.monday
    
    init(dictionary: [String: Any]) {
        lunch = (dictionary["lunch"] as? String) ?? ""
        snack = (dictionary["snack"] as? String) ?? ""
        weekday = TimetableData.Weekday(rawValue: (dictionary["weekday"] as? Int) ?? 0) ?? TimetableData.Weekday.monday
        let rawLessons = dictionary["lessons"] as? [[String: Any]] ?? []
        for rawLesson in rawLessons {
            let lesson = Lesson(dictionary: rawLesson)
            lessons.append(lesson)
        }
    }
    
    init() {}
    
    var dictionaryValue: [String: Any] {
        var dictionary = [String: Any]()
        dictionary["lunch"] = lunch
        dictionary["snack"] = snack
        dictionary["weekday"] = weekday.rawValue
        
        var rawLessons = [[String: Any]]()
        for lesson in lessons {
            rawLessons.append(lesson.dictionaryValue)
        }
        
        dictionary["lessons"] = rawLessons
        
        return dictionary
    }
}
