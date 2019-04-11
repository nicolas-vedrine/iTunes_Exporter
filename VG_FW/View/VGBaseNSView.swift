//
//  VGBaseNSView.swift
//  iTunes Exporter
//
//  Created by Developer on 14/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class VGBaseNSView: NSView {
    
    internal var theState: String?
    internal var theDatas: Any?
    
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
    
    var state: String {
        set {
            theState = newValue
        }
        get {
            return theState!
        }
    }
    
    var datas: Any {
        set {
            theDatas = newValue
        }
        get {
            return theDatas!
        }
    }
    
}
