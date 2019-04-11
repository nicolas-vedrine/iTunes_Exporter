//
//  iTunesTracksListView.swift
//  TestiTunesLibrary
//
//  Created by Developer on 03/04/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa
import iTunesLibrary

class iTunesTracksListView: VGBaseTracksListView {
    
    internal var theiTunesTracks: [ITLibMediaItem]?
    
    /*override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }*/
    
    override func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW___TableViewDoubleClick iTunes : ", self)
    }
    
    override var tracks: [NSObject]? {
        set {
            super.tracks = newValue 
            theiTunesTracks = theTracks as? [ITLibMediaItem]
        }
        get {
            guard let tracks = theiTunesTracks else {
                return nil
            }
            return tracks
        }
    }
    
}

/*extension iTunesTracksListView {
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let item = theiTunesTracks?[row] else {
            return nil
        }
        let cellIdentifier: String = "TitleCellID"
        var text: String = ""
        
        switch tableColumn?.identifier.rawValue {
        case TableColumnID.trackNumberTableColumnID.rawValue:
            text = String(row + 1)
        case TableColumnID.titleTableColumnID.rawValue:
            text = getTrackTitle(theTrack: item)
        case TableColumnID.artistTableColumnID.rawValue:
            text = iTunesModel.getArtistName(theITTrack: item)
        case TableColumnID.albumTableColumnID.rawValue:
            text = iTunesModel.getAlbumTitle(theITTrack: item)
        case TableColumnID.locationTableColumnID.rawValue:
            text = item.location?.path ?? ""
        //text  = item.
        case TableColumnID.totalTimeTableColumnID.rawValue:
            text = getTotalTime(theTrack: item)
        default:
            text = ""
        }
        
        if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField!.stringValue = text
            return cell
        }
        
        return nil
    }
    
    override func getTrackTitle(theTrack: NSObject) -> String {
        let theiTunesTrack: ITLibMediaItem = theTrack as! ITLibMediaItem
        return iTunesModel.getiTunesTrackTitle(theiTunesTrack: theiTunesTrack)
    }
    
    override func getTotalTime(theTrack: NSObject) -> String {
        let theiTunesTrack: ITLibMediaItem = theTrack as! ITLibMediaItem
        return Int(theiTunesTrack.totalTime / 1000).toFormattedDuration()
    }
    
}
*/
