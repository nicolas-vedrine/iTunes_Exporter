//
//  ExportButton.swift
//  iTunes Exporter
//
//  Created by Developer on 21/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class ExportButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var state: NSControl.StateValue {
        set {
            super.state = newValue
            print("V&G_Project___ state : ", newValue)
            let imageName: String = newValue == NSControl.StateValue.on ? "btn_stop" : "btn_play"
            image = NSImage(named: imageName)
        }
        get {
            return super.state
        }
    }
    
}
