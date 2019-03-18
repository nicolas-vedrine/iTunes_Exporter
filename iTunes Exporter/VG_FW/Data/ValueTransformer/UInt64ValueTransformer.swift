//
//  UInt64Transfomer.swift
//  iTunes Exporter
//
//  Created by Developer on 19/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class UInt64ValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        if value != nil {
            let value: UInt64 = value as! UInt64
            let megaBytes: String = value.toMegaBytes()
            return megaBytes
        }
        return ""
    }
    
}

extension NSValueTransformerName {
    static let uint64ValueTransformerName = NSValueTransformerName(rawValue: "UInt64ValueTransformer")
}
