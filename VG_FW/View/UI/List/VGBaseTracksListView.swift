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
    internal var theTracks: [ITLibMediaItem]?
    
    internal func initView() {
        removeColumns()
        
        tracksListTableView.allowsColumnReordering = true
        tracksListTableView.allowsMultipleSelection = true
        tracksListTableView.usesAlternatingRowBackgroundColors = true
        
        tracksListTableView.target = self
        tracksListTableView.doubleAction = #selector(_onTableViewDoubleClick(_:))
    }
    
    @objc func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW____onTableViewDoubleClick : ", self)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override var datas: Any {
        set {
            theDatas = newValue
            theTracks = theDatas as? [ITLibMediaItem]
            tracksListTableView.dataSource = self
            tracksListTableView.delegate = self
        }
        get {
            return theTracks!
        }
    }
    
    var tracks: [ITLibMediaItem]? {
        guard let tracks = theTracks else {
            return nil
        }
        return tracks
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
        return theTracks?.count ?? 0
    }
    
    /*func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        print("V&G_FW___objectValueFor : ", self, tableColumn?.title)
        guard let item = theTracks?[row] else {
            return nil
        }
        switch tableColumn?.title {
        case "":
            return row + 1
        default:
            return item.title
        }
    }*/
    
    /*func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
     print("V&G_FW___setObjectValue : ", self, object)
     }*/
    
    /*func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
        print("V&G_FW___willDisplayCell : ", self)
    }*/
    
    
    
}

extension VGBaseTracksListView: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //print("V&G_FW___viewFor tableColumn : ", self, row)
        guard let item = theTracks?[row] else {
            return nil
        }
        let cellIdentifier: String = "TitleCellID"
        var text: String = ""
        
        switch tableColumn?.identifier.rawValue {
        case TableColumnID.trackNumberTableColumnID.rawValue:
            text = String(row + 1)
        case TableColumnID.titleTableColumnID.rawValue:
            text = item.title
        case TableColumnID.artistTableColumnID.rawValue:
            text = iTunesModel.getArtistName(theITTrack: item)
        case TableColumnID.albumTableColumnID.rawValue:
            text = iTunesModel.getAlbumTitle(theITTrack: item)
        case TableColumnID.locationTableColumnID.rawValue:
            text = item.location?.path ?? ""
            //text  = item.
        case TableColumnID.totalTimeTableColumnID.rawValue:
            text = getTotalTime(time: item.totalTime)
        default:
            text = ""
        }
        
        if let cell: NSTableCellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField!.stringValue = text
            return cell
        }
        
        return nil
    }
    
    @objc internal func getTotalTime(time: Int) -> String {
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
    case totalTimeTableColumnID = "TotalPlayedTime"
    
}

struct ColumnsListStruct {
    
    let title: String
    let id: TableColumnID
    
    init(title: String, id: TableColumnID) {
        self.title = title
        self.id = id
    }
    
}
