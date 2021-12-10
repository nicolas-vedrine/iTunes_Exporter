//
//  AppDelegate.swift
//  iTunes Exporter
//
//  Created by Developer on 24/01/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    override init() {
        ValueTransformer.setValueTransformer(DurationValueTransformer(), forName: .durationValueTransformerName)
        ValueTransformer.setValueTransformer(UInt64ValueTransformer(), forName: .uint64ValueTransformerName)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /*public init(_ coder: NSCoder? = nil) {
            if let coder = coder {
                super.init(coder: coder)
            }
    }*/


}

