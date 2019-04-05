//
//  DurationValueTransformer.swift
//  iTunes Exporter
//
//  Created by Developer on 18/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class DurationValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value != nil {
            let value: Int = value as! Int / 1000
            let formattedDuration: String = value.toFormattedDuration()
            return formattedDuration
        }
        return ""
    }
    
}

extension NSValueTransformerName {
    static let durationValueTransformerName = NSValueTransformerName(rawValue: "DurationValueTransformer")
}
