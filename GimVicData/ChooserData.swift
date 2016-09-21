//
//  ChooserData.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/20/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import Foundation

public enum ChooserDataStatus {
    case success, networkError, error
}

public protocol ChooserDataDelegate {
    func chooserDataDidUpdateWithStatus(_ status: ChooserDataStatus)
}

public final class ChooserData {
    public static let sharedInstance = ChooserData()
    
    public var mainClasses = [String]()
    public var additionalClasses = [String]()
    public var teachers = [String]()
    public var snackTypes = [String]()
    public var lunchTypes = [String]()
    
    public var delegates = [DelegateID: ChooserDataDelegate]()
    
    var downloading = false
    
    public enum DelegateID: Int {
        case settingsViewController
        case setupViewController
    }
    
    enum DictionaryTypes: String {
        case mainClasses = "main_classes"
        case additionalClasses = "additional_classes"
        case teachers = "teachers"
        case snackTypes = "snack_types"
        case lunchTypes = "lunch_types"
    }
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsPath = paths.first {
            let chooserDataPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("chooserData.plist")
            if let chooserData = NSDictionary(contentsOf: chooserDataPath) as? [String: [String]] {
                mainClasses = chooserData[DictionaryTypes.mainClasses.rawValue] ?? []
                additionalClasses = chooserData[DictionaryTypes.additionalClasses.rawValue] ?? []
                teachers = chooserData[DictionaryTypes.teachers.rawValue] ?? []
                snackTypes = chooserData[DictionaryTypes.snackTypes.rawValue] ?? []
                lunchTypes = chooserData[DictionaryTypes.lunchTypes.rawValue] ?? []
            }
        }
    }
    
    public func save() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentsPath = paths.first {
            let chooserDataPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("chooserData.plist")
            let saveData: NSDictionary = [DictionaryTypes.mainClasses.rawValue: mainClasses,
                                          DictionaryTypes.additionalClasses.rawValue: additionalClasses,
                                          DictionaryTypes.teachers.rawValue: teachers,
                                          DictionaryTypes.snackTypes.rawValue: snackTypes,
                                          DictionaryTypes.lunchTypes.rawValue: lunchTypes]
            saveData.write(to: chooserDataPath, atomically: true)
        }
    }
    
    public var isDataValid: Bool {
        return !(mainClasses.isEmpty || additionalClasses.isEmpty ||
                teachers.isEmpty || snackTypes.isEmpty || lunchTypes.isEmpty)
    }
    
    public func update() {
        if downloading {
            return
        }
        downloading = true
        
        let url = ConstantProperties.serverURL.appendingPathComponent("chooserOptions")
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
            if error != nil {
                if error!._domain == NSURLErrorDomain {
                    self.refreshDelegates(.networkError)
                } else {
                    self.refreshDelegates(.error)
                }
                
                self.downloading = false
                return
            }
            
            do {
                if let data = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: [String]] {
                    if let parsedData = data["mainClasses"] {
                        self.mainClasses = parsedData
                    }
                    if let parsedData = data["additionalClasses"] {
                        self.additionalClasses = parsedData
                    }
                    if let parsedData = data["teachers"] {
                        self.teachers = parsedData
                    }
                    if let parsedData = data["snackTypes"] {
                        self.snackTypes = parsedData
                    }
                    if let parsedData = data["lunchTypes"] {
                        self.lunchTypes = parsedData
                    }
                    
                    self.refreshDelegates(.success)
                } else {
                    self.refreshDelegates(.error)
                }
            } catch {
                self.refreshDelegates(.error)
            }
            self.downloading = false
        }).resume()
    }
    
    public func refreshDelegates(_ status: ChooserDataStatus) {
        DispatchQueue.main.async {
            for delegate in self.delegates.values {
                delegate.chooserDataDidUpdateWithStatus(status)
            }
        }
    }
}
