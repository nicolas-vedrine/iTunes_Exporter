//
//  iTunesTracksListView.swift
//  TestiTunesLibrary
//
//  Created by Developer on 03/04/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class iTunesTracksListView: VGBaseTracksListView, VGLoadableNib {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var iTunesTracksListTableView: NSTableView!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        tracksListTableView = iTunesTracksListTableView
        initView()
    }
    
    override func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW___TableViewDoubleClick iTunes : ", self)
    }
    
}

extension iTunesTracksListView {
    
    override func getTotalTime(time: Int) -> String {
        return Int(time / 1000).toFormattedDuration()
    }
    
}
