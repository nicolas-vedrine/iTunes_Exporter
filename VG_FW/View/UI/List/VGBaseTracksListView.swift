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
    var arrayController: NSArrayController!
    
    internal func initView() {
        removeColumns()
        
        tracksListTableView.allowsColumnReordering = true
        tracksListTableView.allowsMultipleSelection = true
        tracksListTableView.usesAlternatingRowBackgroundColors = true
        
        tracksListTableView.dataSource = self
        tracksListTableView.delegate = self
        
        tracksListTableView.target = self
        tracksListTableView.doubleAction = #selector(_onTableViewDoubleClick(_:))
        
        arrayController = NSArrayController()
        
        tracksListTableView.bind(.content, to: arrayController, withKeyPath: "arrangedObjects", options: nil)
    }
    
    @objc func _onTableViewDoubleClick(_ sender: AnyObject) {
        print("V&G_FW____onTableViewDoubleClick : ", self)
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        print("V&G_FW___keyDown : ", event.keyCode)
        if event.keyCode == 117 {
            let theIndexSet = self.tracksListTableView.selectedRowIndexes
            removeTracks(theIndexesToRemove: theIndexSet)
        }
    }
    
    var tracks: [NSObject]? {
        set {
            datas = newValue
            arrayController.removeAll()
            for theTrack in datas as! [NSObject] {
                arrayController.addObject(theTrack)
            }
        }
        get {
            if let theArrayCollection: NSArrayController = arrayController {
                let theTracks = theArrayCollection.arrangedObjects as! [NSObject]
                return theTracks
            }
            return nil
        }
    }
    
    // récupération de la selection de piste. doit être dans un tableau récupéré à partir de la selection dans la tableView puis on cherche dans le arrayController
    var selectedTracks: [NSObject]? {
        get {
            if tracksListTableView.selectedRowIndexes.count > 0 {
                var selectedTracks: [NSObject] = [NSObject]()
                let selectedIndexes: IndexSet = tracksListTableView.selectedRowIndexes
                let theTracks: [NSObject] = arrayController.arrangedObjects as! [NSObject]
                for theIndex in selectedIndexes {
                    let theTrack = theTracks[theIndex]
                    selectedTracks.append(theTrack)
                }
                return selectedTracks
            }
            return nil
        }
    }
    
    func removeTracks(theIndexesToRemove: IndexSet) {
        if _isEnabled {
            if tracksListTableView.selectedRowIndexes.count > 0 {
                let theSelectedTracks: [NSObject] = selectedTracks!
                arrayController.remove(atArrangedObjectIndexes: theIndexesToRemove)
                let theTracks = arrayController.arrangedObjects as! [NSObject]
                print("V&G_FW___removeTracks : ", theTracks.count)
                NotificationCenter.default.post(name: .TRACKS_DELETED, object: theSelectedTracks)
            }
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
        if tracks != nil {
            let cellIdentifier: String = "TracksListCellID"
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
