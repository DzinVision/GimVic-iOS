//
//  JedilnikDataFetch.swift
//  GimVic
//
//  Created by Vid Drobnic on 11/9/15.
//  Copyright © 2015 Vid Drobnič. All rights reserved.
//

import Foundation

class JedilnikDataFetch {
    static let sharedInstance = JedilnikDataFetch()
    var isDownloading = false;
    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    
    var jedilnik = [String: [[String: [String]]]]()
    
    init() {
        if jedilnik.isEmpty {
            jedilnik = NSDictionary(contentsOfFile: "\(documentsPath)/jedilnik") as? [String: [[String: [String]]]] ?? [String: [[String: [String]]]]()
        }
    }
    
    enum Days: Int {
        case Monday = 0, Tuesday, Wednesday, Thursday, Friday
    }
    
    enum MalicaType: String {
        case Navadna = "Navadna", VegSPerutnino = "VegSPerutnino", Vegetarijanska = "Vegetarijanska", SadnoZelenjavna = "SadnoZelenjavna"
    }
    
    enum KosiloType: String {
        case Navadno = "Navadno", Vegetarijansko = "Vegetarijansko"
    }
    
    func downloadJedilnik() {
        if isDownloading {
            return
        }
        
        isDownloading = true

        var today = NSDate()
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        let weekday = calendar.component(NSCalendarUnit.Weekday, fromDate: today)
        if weekday == 7 {
            today = today.dateByAddingTimeInterval(24 * 3600)
        }
        
        let components = calendar.components(NSCalendarUnit.Weekday, fromDate: today)
        let componentsToSubstract = NSDateComponents()
        componentsToSubstract.day = -(components.weekday - calendar.firstWeekday)
        let sunday = calendar.dateByAddingComponents(componentsToSubstract, toDate: today, options: NSCalendarOptions(rawValue: 0))!
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var malicaData = [[String: [String]]]()
        var kosiloData = [[String: [String]]]()
        
        for i in 1...5 {
            do {
                let date = formatter.stringFromDate(sunday.dateByAddingTimeInterval(Double(i * 24 * 3600)))
                let url = NSURL(string: "http://app.gimvic.org/APIv2/jedilnikAPI/getJedilnikForDate.php?date=\(date)&type=malica")!
                let data = NSData(contentsOfURL: url)
                
                if data == nil {
                    malicaData.append([String: [String]]())
                } else {
                    try malicaData.append(NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String : [String]])
                }
            } catch _ {
                malicaData.append([String: [String]]())
            }
            
            do {
                let date = formatter.stringFromDate(sunday.dateByAddingTimeInterval(Double(i * 24 * 3600)))
                let url = NSURL(string: "http://app.gimvic.org/APIv2/jedilnikAPI/getJedilnikForDate.php?date=\(date)&type=kosilo")!
                let data = NSData(contentsOfURL: url)
                
                if data == nil {
                    kosiloData.append([String: [String]]())
                } else {
                    try kosiloData.append(NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [String : [String]])
                }
            } catch _ {
                kosiloData.append([String: [String]]())
            }
        }
        
        let resultDictionary = ["malica": malicaData, "kosilo": kosiloData]
        NSDictionary(dictionary: resultDictionary).writeToFile("\(documentsPath)/jedilnik", atomically: true)
    }
    
    func malicaForDay(day: Days, type: MalicaType) -> [String] {
        return jedilnik["malica"]![day.rawValue][type.rawValue]!
    }
    
    func kosiloForDay(day: Days, type: KosiloType) -> [String] {
        return jedilnik["kosilo"]![day.rawValue][type.rawValue]!
    }
}