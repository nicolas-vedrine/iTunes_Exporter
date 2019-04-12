//
//  TracksListView.swift
//  TestiTunesLibrary
//
//  Created by Developer on 03/04/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa
import iTunesLibrary

class VGBaseTracksListView: VGBaseNSView {
    
    var tracksListTableView: NSTableView!
    //internal var theTracks: [NSObject]?
    
    internal func initView() {
        removeColumns()
        
        tracksListTableView.allowsColumnReordering = true
        tracksListTableView.allowsMultipleSelection = true
        tracksListTableView.usesAlternatingRowBackgroundColors = true
        
        tracksListTableView.dataSource = self
        tracksListTableView.delegate = self
        
        tracksListTableView.target = self
        tracksListTableView.doubleAction = #selector(_onTableViewDoubleClick(_:))
    }
    
    @objc func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW____onTableViewDoubleClick : ", self)
    }
    
    /*override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }*/
    
    var tracks: [NSObject]? {
        set {
            datas = newValue
            //theTracks = theDatas as? [NSObject]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                self!.tracksListTableView.reloadData()
            }
            //tracksListTableView.reloadData()
        }
        get {
            if let tracks: [NSObject] = datas as? [NSObject] {
                return tracks
            }
            return nil
        }
    }
    
    var selectedTracks: [NSObject]? {
        get {
            if let tracks = tracks {
                var theSelectedTracks = [NSObject]()
                let theIndexSet = self.tracksListTableView.selectedRowIndexes
                for theIndex in theIndexSet {
                    theSelectedTracks.append(tracks[theIndex])
                }
                return theSelectedTracks
            }
            return nil
        }
    }
    
    func buildColumns(columnsList: [ColumnsListStruct]) {
        for columnStruct in columnsList {
            let columnID: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: columnStruct.id.rawValue)
            let column: NSTableColumn = NSTableColumn(identifier: columnID)
            column.title = columnStruct.title
            tracksListTableView.addTableColumn(column)
        }
        tracksListTableView.reloadData()
    }
    
    func removeColumns() {
        for column in tracksListTableView.tableColumns {
            tracksListTableView.removeTableColumn(column)
        }
    }
    
}

extension VGBaseTracksListView: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let tracks = tracks {
            print("V&G_FW___numberOfRows : ", self, tracks.count)
            return tracks.count
        }
        return 0
    }
}

extension VGBaseTracksListView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let tracks = tracks {
            let cellIdentifier: String = "TracksListCellID"
            let item = tracks[row]
            let text = "text : " + String(row + 1)
            if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField!.stringValue = text
                return cell
            }
        }
        
        return nil
    }
    
    @objc internal func getTrackTitle(theTrack: NSObject) -> String {
        return ""
    }
    
    @objc internal func getTrackArtistName(theTrack: NSObject) -> String {
        return ""
    }
    
    @objc internal func getTrackAlbumName(theTrack: NSObject) -> String {
        return ""
    }
    
    @objc internal func getTotalTime(theTrack: NSObject) -> String {
        let time: Int = 0
        return time.toFormattedDuration()
    }
    
}

enum TableColumnID: String {
    
    case trackNumberTableColumnID = "TrackNumberTableColumnID"
    case titleTableColumnID = "TitleTableColumnID"
    case artistTableColumnID = "ArtistTableColumnID"
    case albumTableColumnID = "AlbumTableColumnID"
    case locationTableColumnID = "LocationTableColumnID"
    case kindTableColumnID = "KindTableColumnID"
    case totalTimeTableColumnID = "TotalPlayedTimeID"
    
}

struct ColumnsListStruct {
    
    let title: String
    let id: TableColumnID
    
    init(title: String, id: TableColumnID) {
        self.title = title
        self.id = id
    }
    
}
