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
    
}

extension Int {
    
    func toTimeFormatted(digits: Int = 1) -> String {
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
