//
//  TopBarView.swift
//  iTunes Exporter
//
//  Created by Developer on 13/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class TopBarView: NSView {

    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func updateLayer() {
        if #available(OSX 10.13, *) {
            self.layer?.backgroundColor = NSColor(named: "bg")?.cgColor
        } else {
            // Fallback on earlier versions
        }
    }
    
}
