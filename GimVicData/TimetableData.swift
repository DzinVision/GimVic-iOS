//
//  TimetableData.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import Foundation

public protocol TimetableDataDelegate {
    func timetableDataDidUpdateWithStatus(_ status: DataGetterStatus)
}

public final class TimetableData {
    public static let sharedInstance = TimetableData()
    
    var timetableEntries = [Weekday: TimetableEntry]()
    var isDownloading = false
    
    public var delegates = [DelegateID: TimetableDataDelegate]()
    
    public enum DelegateID: Int {
        case monday = 0, tuesday, wednesday, thursday, friday
    }
    
    public enum Weekday: Int {
        case monday = 0, tuesday, wednesday, thursday, friday
    }
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsPath = paths.first {
            let dataPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("timetableData.plist")
            if let timetableData = NSArray(contentsOf: dataPath) as? [[String: Any]] {
                for rawTimetableEntry in timetableData {
                    let timetableEntry = TimetableEntry(dictionary: rawTimetableEntry)
                    timetableEntries[timetableEntry.weekday] = timetableEntry
                }
            }
        }
    }
    
    public func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsPath = paths.first {
            let dataPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("timetableData.plist")
            var rawData = [[String: Any]]()
            for timetableEntry in timetableEntries.values {
                rawData.append(timetableEntry.dictionaryValue)
            }
            
            (rawData as NSArray).write(to: dataPath, atomically: true)
        }
    }
    
    public func timetableEntryFor(_ day: Weekday) -> TimetableEntry {
        return timetableEntries[day] ?? TimetableEntry()
    }
    
    public func update() {
        if isDownloading {
            return
        }
        isDownloading = true
        
        UserDefaults().set(Date(), forKey: UserSettings.lastRefreshedTimetableData.rawValue)
        
        guard let url = generateURL() else {
            isDownloading = false
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil {
                if error!._domain == NSURLErrorDomain {
                    self.refreshDelegates(.networkError)
                } else {
                    self.refreshDelegates(.error)
                }
                
                self.isDownloading = false
                return
            }
            
            do {
                if let data = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
                    let days = data["days"] as? [[String: Any]] ?? []
                    for j in 0..<days.count {
                        let day = days[j]
                        let lunchLines = day["lunchLines"] as? [String] ?? []
                        var lunch = ""
                        for lunchLine in lunchLines {
                            lunch += lunchLine
                            if lunchLine != lunchLines.last {
                                lunch += ", "
                            }
                        }
                        
                        let snackLines = day["snackLines"] as? [String] ?? []
                        var snack = ""
                        for snackLine in snackLines {
                            snack += snackLine
                            if snackLine != snackLines.last {
                                snack += ", "
                            }
                        }
                        
                        var lessons = [Lesson]()
                        let rawLessons = day["lessons"] as? [[String: Any]] ?? []
                        for i in 0..<rawLessons.count {
                            if rawLessons[i].isEmpty {
                               continue
                            }
                            
                            let classes = rawLessons[i]["classes"] as? [String] ?? []
                            let classrooms = rawLessons[i]["classrooms"] as? [String] ?? []
                            let subjects = rawLessons[i]["subjects"] as? [String] ?? []
                            let teachers = rawLessons[i]["teachers"] as? [String] ?? []
                            let note = rawLessons[i]["note"] as? String
                            let substitution = rawLessons[i]["substitution"] as? Bool ?? false
                            
                            var lesson = Lesson()
                            lesson.hour = i + 1
                            lesson.classes = classes
                            lesson.classrooms = classrooms
                            lesson.subjects = subjects
                            lesson.teachers = teachers
                            lesson.substitution = substitution
                            lesson.note = note
                            
                            lessons.append(lesson)
                        }
                        
                        var timetableEntry = TimetableEntry()
                        timetableEntry.lessons = lessons
                        timetableEntry.lunch = lunch
                        timetableEntry.snack = snack
                        timetableEntry.weekday = TimetableData.Weekday(rawValue: j)!
                        
                        self.timetableEntries[timetableEntry.weekday] = timetableEntry
                    }
                    
                    self.refreshDelegates(.success)
                } else {
                    self.refreshDelegates(.error)
                }
            } catch {
                self.refreshDelegates(.error)
            }
            self.isDownloading = false
        }).resume()
        
        
    }
    
    func refreshDelegates(_ status: DataGetterStatus) {
        DispatchQueue.main.async {
            for delegate in self.delegates.values {
                delegate.timetableDataDidUpdateWithStatus(status)
            }
        }
    }
    
    func generateURL() -> URL? {
        var url = ConstantProperties.serverURLString
        
        UserDefaults().set(Date(), forKey: UserSettings.lastRefreshedTimetableData.rawValue)
        let profesorType = UserDefaults().bool(forKey: UserSettings.profesorFilter.rawValue)

        if profesorType {
            url += "/teacherData?"
        } else {
            url += "/data?"
        }
        
        let addSubstitutions = UserDefaults().bool(forKey: UserSettings.showSubstitutions.rawValue)
        url += "addSubstitutions=\(addSubstitutions)&"
        
        guard let filter = UserDefaults().string(forKey: UserSettings.filter.rawValue) else {
            return nil
        }
        if profesorType {
            url += "teacher=\(filter)&"
        } else {
            url += "classes[]=\(filter)&"
            let classNumber = Int(filter.substring(to: filter.index(after: filter.startIndex))) ?? 0
            
            let key: String
            if classNumber == 3 {
                key = UserSettings.izbirniPredmeti.rawValue
            } else {
                key = UserSettings.maturitetniPredmeti.rawValue
            }
            
            let selected = (UserDefaults().array(forKey: key) as? [String]) ?? []
            for item in selected {
                url += "classes[]=\(item)&"
            }
        }
        
        let snack = UserDefaults().string(forKey: UserSettings.snack.rawValue)!
        let lunch = UserDefaults().string(forKey: UserSettings.lunch.rawValue)!
        
        url += "snackType=\(snack)&lunchType=\(lunch)"
        
        return URL(string: url)!
    }
}
