//
//  VGBaseNSViewController.swift
//  iTunes Exporter
//
//  Created by Developer on 16/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class VGBaseNSViewController: NSViewController {
    
    var data: Any?
    
    internal var observers: [NSObjectProtocol] = [NSObjectProtocol]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildView()
    }
    
    internal func buildView() {
        print("V&G_FW___buildView : ", self)
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        addObservers()
        print("V&G_FW___viewDidAppear : ", self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        removeObservers()
    }
    
    internal func addObservers() {
        print("V&G_FW___addObservers", self)
    }
    
    internal func removeObservers() {
        print("V&G_FW___removeObservers : ", self)
        for observer: NSObjectProtocol in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }
    
    
    
}
