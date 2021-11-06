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
    
    override func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW___TableViewDoubleClick iTunes : ", self)
    }
    
    override var tracks: [NSObject]? {
        set {
            super.tracks = newValue
        }
        get {
            /*guard let tracks = theDatas else {
                return nil
            }
            return tracks as! [ITLibMediaItem]*/
            
            
            /*if let theArrayCollection: NSArrayController = arrayController {
                let theTracks = theArrayCollection.arrangedObjects as! [ITLibMediaItem]
                return theTracks
            }
            return nil*/
            
            return super.tracks
        }
    }
    
    func filterTracks(theStr: String) {
        let theTracks: [ITLibMediaItem] = (tracks! as? [ITLibMediaItem])!
        let theSearch = theTracks.filter({($0.artist?.name?.lowercased().contains(theStr))!})
        print("V&G_Project___filterTracks : ", theStr + " " + String(theSearch.count))
        datas = theSearch
        tracksListTableView.reloadData()
    }
    
}

extension iTunesTracksListView {
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let theArrayCollection: NSArrayController = arrayController {
            let theTracks = theArrayCollection.arrangedObjects as! [ITLibMediaItem]
            let theTrack = theTracks[row]
            let cellIdentifier: String = "TracksListCellID"
            var text: String = ""
            
            switch tableColumn?.identifier.rawValue {
            case TableColumnID.trackNumberTableColumnID.rawValue:
                text = String(row + 1)
            case TableColumnID.titleTableColumnID.rawValue:
                text = getTrackTitle(theTrack: theTrack)
            case TableColumnID.artistTableColumnID.rawValue:
                text = iTunesModel.getArtistName(theITTrack: theTrack)
               // text = (theTrack.artist?.name)!
            case TableColumnID.albumTableColumnID.rawValue:
                text = iTunesModel.getAlbumTitle(theITTrack: theTrack)
                //text = theTrack.album.title!
            case TableColumnID.locationTableColumnID.rawValue:
                text = theTrack.location?.path ?? ""
            case TableColumnID.totalTimeTableColumnID.rawValue:
                text = getTotalTime(theTrack: theTrack)
            default:
                text = ""
            }
            
            if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField!.stringValue = text
                return cell
            }
        }        
        
        print("V&G_FW___viewFor tableColumn : ", self, "no TitleCellID is present !")
        
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
