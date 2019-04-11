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
    internal var theTracks: [NSObject]?
    
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
            datas = newValue as Any
            theTracks = theDatas as? [NSObject]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                self!.tracksListTableView.reloadData()
            }
            //tracksListTableView.reloadData()
        }
        get {
            guard let tracks = theTracks else {
                return nil
            }
            return tracks
        }
    }
    
    var selectedTracks: [NSObject] {
        get {
            var theSelectedTracks = [NSObject]()
            let theIndexSet = self.tracksListTableView.selectedRowIndexes
            for theIndex in theIndexSet {
                theSelectedTracks.append(theTracks![theIndex])
            }
            return theSelectedTracks
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
        print("V&G_FW___numberOfRows : ", self, theTracks?.count)
        return theTracks?.count ?? 0
    }
}

extension VGBaseTracksListView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let item = theTracks?[row] else {
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
            text = getTrackArtistName(theTrack: item)
        case TableColumnID.albumTableColumnID.rawValue:
            text = getTrackAlbumName(theTrack: item)
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