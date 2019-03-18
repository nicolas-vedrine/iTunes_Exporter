//
//  PlaylistTableCellView.swift
//  Swift-AppleScriptObjC
//
//  Created by Developer on 23/01/2019.
//

import Cocoa

class PlaylistTableCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func buildCell(thePlaylist: Playlist) {
        if thePlaylist.isFolder {
            imageView?.image = NSImage(named: "folder-playlist-icon")
        } else if thePlaylist.isSmart {
            imageView?.image = NSImage(named: "smart-playlist-icon")
        } else {
            imageView?.image = NSImage(named: "normal-playlist-icon")
        }
    }
    
}
