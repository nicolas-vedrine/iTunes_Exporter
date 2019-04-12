//
//  VGBaseNSView.swift
//  iTunes Exporter
//
//  Created by Developer on 14/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class VGBaseNSView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buildView()
    }
    
    internal func buildView() -> Void {
        print("V&G_FW___buildView : ", self)
    }
    
}
