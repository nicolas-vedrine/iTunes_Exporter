//
//  Types.swift
//  Video & Go
//
//  Created by Developer on 05/11/2018.
//  Copyright © 2018 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

extension Data
{
    func toString() -> String
    {
        return String(data: self, encoding: .utf8)!
    }
}

extension String {
    
    func toDate(withFormat format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else {
            preconditionFailure("Take a look to your format")
        }
        return date
    }
    
    func toDateFromTimeStamp() -> Date {
        let double = Double(self)
        let date = Date(timeIntervalSince1970: double!)
        return date
    }
    
    var replacingHTMLEntities: String? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
                ], documentAttributes: nil).string
        } catch {
            return nil
        }
    }
    
}

extension UInt64 {
    
    func toMegaBytes() -> String {
        let formatter:ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: Int64(bitPattern: self))
    }
    
}

extension Int {
    
    /*func toTimeFormatted(digits: Int = 1) -> String {
        var digitsString: String = ""
        var timeFormatted: String = ""
        if self < 10 {
            for _ in 1...digits {
                digitsString += "0"
            }
        }
        timeFormatted = digitsString + String(self)
        return timeFormatted
    }
    
    static func formatLessThanTen(nValue: Int) -> String {
        var sValue:String
        sValue = nValue < 10 ? String("0" + String(nValue)) : String(nValue)
        return sValue
    }
    
    static func getSecondes(nSec: Int) -> Int {
        let nSecondes: Int = nSec % 60
        return nSecondes
    }
    
    static func getMinutes(nSec: Int) -> Int {
        var nMinutes: Int = Int(Double(nSec / 60).rounded(.toNearestOrAwayFromZero))
        nMinutes = nMinutes % 60
        return nMinutes
    }
    
    static func getHours(nMin: Int) -> Int {
        var nHours: Int = Int(Double(nMin / 60).rounded(.toNearestOrAwayFromZero))
        nHours = nHours % 24
        return nHours
    }
    
    static func getDays(nHours: Int) -> Int {
        let nDays: Int = Int(Double(nHours / 24).rounded(.toNearestOrAwayFromZero))
        return nDays
    }
    
    static func getMounth(nDays: Int) -> Int {
        let nMonths: Int = Int(Double(nDays / 31).rounded(.toNearestOrAwayFromZero))
        return nMonths
    }
    
    static func getYears(nMouths: Int) -> Int{
        let nYears: Int = Int(Double(nMouths / 12).rounded(.toNearestOrAwayFromZero))
        return nYears
    }
    
    static func getTime(secondes: Int) -> TimeObject {
        let nSecondes: Int = getSecondes(nSec: secondes)
        let nMinutes: Int = getMinutes(nSec: secondes)
        let nHours: Int = getHours(nMin: Int(Double(Int(Double(secondes / 60).rounded(.toNearestOrAwayFromZero))).rounded(.toNearestOrAwayFromZero)))
        let nDays: Int = getDays(nHours: Int(Double(Double(secondes / 60).rounded(.toNearestOrAwayFromZero) / 60).rounded(.toNearestOrAwayFromZero)))
        let nMonths: Int = getMounth(nDays: nDays)
        let nYears: Int = getYears(nMouths: nMonths)
        let timeObj: TimeObject = TimeObject(nSec: nSecondes, nMinutes: nMinutes, nHours: nHours, nDays: nDays, nMouths: nMonths, nYears: nYears)
        return timeObj
    }
    
    static func getFormatedTime(secondes: Int, delimiter: String = ":") -> String {
        print("V&G_FW___getFormatedTime : ", secondes)
        let timeObj:TimeObject = getTime(secondes: secondes)
        let sTime:String = formatLessThanTen(nValue: timeObj.days) + delimiter + formatLessThanTen(nValue: timeObj.hours) + delimiter + formatLessThanTen(nValue: timeObj.minutes) + delimiter + formatLessThanTen(nValue: timeObj.seconds)
        return sTime
    }*/
    
    func toFormattedDuration(unitsStyle: DateComponentsFormatter.UnitsStyle = .positional) -> String {
        let duration: TimeInterval = TimeInterval(self) // 701429
        var calendar = Calendar.current
        let locale = String(Locale.preferredLanguages[0].prefix(2))
        calendar.locale = Locale(identifier: locale)
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.calendar = calendar
        durationFormatter.unitsStyle = unitsStyle
        durationFormatter.allowedUnits = [.day, .hour, .minute, .second ]
        durationFormatter.zeroFormattingBehavior = [ .dropMiddle ]
        let formattedDuration = durationFormatter.string(from: duration)
        return formattedDuration!
    }
    
    func toTrackDurationFormat() -> String {
        let duration: TimeInterval = TimeInterval(self)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration)!
            .replacingOccurrences(of: #"^00[:.]0?|^0"#, with: "", options: .regularExpression)
    }
    
    func toFormattedNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = " "
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self))!
    }
    
}

struct TimeObject {
    
    let seconds: Int
    let minutes: Int
    let hours: Int
    let days: Int
    let months: Int
    let years: Int
    
    init(nSec: Int, nMinutes: Int, nHours: Int, nDays: Int, nMouths: Int, nYears: Int) {
        self.seconds = nSec
        self.minutes = nMinutes
        self.hours = nHours
        self.days = nDays
        self.months = nMouths
        self.years = nYears
    }
    
}

extension Date {
    
    func timeAgoObj() -> TimeAgoObject {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        
        var timeAgoObject: TimeAgoObject?
        
        if secondsAgo < minute {
            timeAgoObject = TimeAgoObject(time: secondsAgo, type: TimeAgoType.second)
            //return "\(secondsAgo) seconds ago"
        } else if secondsAgo < hour {
            timeAgoObject = TimeAgoObject(time: secondsAgo / minute, type: TimeAgoType.minute)
            //return "\(secondsAgo / minute) minutes ago"
        } else if secondsAgo < day {
            timeAgoObject = TimeAgoObject(time: secondsAgo / hour, type: TimeAgoType.hour)
            //return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            timeAgoObject = TimeAgoObject(time: secondsAgo / day, type: TimeAgoType.day)
            //return "\(secondsAgo / day) days ago"
        }else {
            timeAgoObject = TimeAgoObject(time: secondsAgo / week, type: TimeAgoType.week)
            //return "\(secondsAgo / week) weeks ago"
        }
        return timeAgoObject!
    }
    
    enum TimeAgoType: String {
        case second = "second"
        case minute = "minute"
        case hour = "hour"
        case day = "day"
        case week = "week"
        case mouth = "mouth"
        case year = "year"
    }
    
    func toString() -> String {
        let formatterToString = DateFormatter()
        return formatterToString.string(from: self)
    }
    
}

struct TimeAgoObject {
    var time: Int
    var type: Date.TimeAgoType
}

enum DateFormatType: String {
    
    case fr_FR_day = "EEEE dd MMMM YYYY"
    case fr_FR_hour = "HH:mm"
    
}

extension Array {
    
    /*func flatten<T>(_ index: Int = 0) -> [T] {
        guard index < self.count else {
            return []
        }
        
        var flatten: [T] = []
        
        if let itemArr = self[index] as? [T] {
            flatten += itemArr.flatten()
        } else if let element = self[index] as? T {
            flatten.append(element)
        }
        return flatten + self.flatten(index + 1)
    }*/
    
    func flatten(_ array: [Any]) -> [Any] {
        var result = [Any]()
        for element in array {
            if let element = element as? [Any] {
                result.append(contentsOf: flatten(element))
            } else {
                result.append(element)
            }
        }
        return result
    }
    
}

extension NSArrayController {
    
    func removeAll() {
        let range : NSRange = NSMakeRange(0, (self.arrangedObjects as AnyObject).count)
        let indexSet : NSIndexSet = NSIndexSet(indexesIn: range)
        
        self.remove(atArrangedObjectIndexes: indexSet as IndexSet)
    }
    
}


extension FileManager {
    
    static func getRootPath(thePath: URL) -> String {
        let thePathComponents: [String] = thePath.pathComponents
        let sep: String = "/"
        var theRootPath: String = sep
        for i in 1...2 {
            let theComponent: String = thePathComponents[i]
            theRootPath += theComponent
            theRootPath += sep
        }
        return theRootPath
    }
    
    static func hasEnoughSpace(thePath: URL, theSize: UInt64) -> Bool {
        do {
            print("V&G_FW___FileManager hasEnoughSpace : ", thePath)
            let theRootPath: String = FileManager.getRootPath(thePath: thePath)
            print("V&G_FW___FileManager hasEnoughSpace : ", theRootPath)
            let du = try FileManager.default.attributesOfFileSystem(forPath: theRootPath)
            if let size = du[FileAttributeKey.systemFreeSize] as? Int64 {
                return size >= theSize
            }
        } catch {
            print("V&G_FW___FileManager hasEnoughSpace : ", "error")
            return false
        }
        return false
    }
    
    static func getFreeSpace(thePath: URL) -> Int64? {
        do {
            let theRootPath: String = FileManager.getRootPath(thePath: thePath)
            let du = try FileManager.default.attributesOfFileSystem(forPath: theRootPath)
            if let size = du[FileAttributeKey.systemFreeSize] as? Int64 {
                return size
            }
        } catch {
            print("V&G_FW___FileManager getFreeSpace : ", "error")
            return nil
        }
        return nil
    }
    
}

extension URL {
    
    func isMostRecenThan(url: URL, _ fileManager: FileManager = FileManager.default) -> Bool {
        return self.getModificationDate(fileManager)! > url.getModificationDate(fileManager)!
    }
    
    func isPathExists(_ fileManager: FileManager = FileManager.default) -> Bool {
        return fileManager.fileExists(atPath: self.path)
    }
    
    func getModificationDate(_ fileManager: FileManager = FileManager.default) -> Date? {
        do {
            let attr = try fileManager.attributesOfItem(atPath: self.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    func getName() -> String? {
        let thePathComponents: [String] = self.pathComponents
        //print("V&G_FW___getName : ", self, thePathComponents)
        if thePathComponents.count > 0 {
            let theName = thePathComponents[thePathComponents.count - 1]
            return theName
        }
        return nil
    }
    
    func getFileExtension() -> String {
        let theFileName: String = self.getName()!
        let theFileNameComponents: [String] = theFileName.components(separatedBy: ".")
        let theFileExtension: String = theFileNameComponents[theFileNameComponents.count - 1]
        return theFileExtension
    }
    
    func getParentFolderName() -> String {
        let thePathComponents: [String] = self.pathComponents
        return thePathComponents[thePathComponents.count - 2]
    }
    
    func getFileNameWithoutExtension() -> String {
        let theFileName: String = self.getName()!
        let theFileExtension: String = self.getFileExtension()
        let theStartIndex = theFileName.startIndex
        let theEndIndex = theFileName.index(theFileName.endIndex, offsetBy: -(theFileExtension.count + 1))
        let theFileNameWithoutExtension = theFileName[theStartIndex..<theEndIndex]
        return String(theFileNameWithoutExtension)
    }
    
}

extension NSView {
    
    func getConstraint(byIdentifier identifier: String) -> NSLayoutConstraint? {
        for constraint in constraints {
            print("V&G_FW___getConstraint : ", self, constraint.identifier)
            if constraint.identifier == identifier {
                return constraint
            }
        }
        return nil
    }
    
}

struct MessageBoxResult {
    
    let response: NSApplication.ModalResponse
    let isRemembered: Bool
    
    init(response: NSApplication.ModalResponse, isRemembered: Bool) {
        self.response = response
        self.isRemembered = isRemembered
    }
    
}
