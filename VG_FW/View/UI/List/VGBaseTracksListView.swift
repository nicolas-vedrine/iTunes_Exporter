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
            removeTracks(theTracksToRemove: selectedTracks!)
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
            /*if let tracks: [NSObject] = datas as? [NSObject] {
                return tracks
            }*/
            if let theArrayCollection: NSArrayController = arrayController {
                let theTracks = theArrayCollection.arrangedObjects as! [NSObject]
                return theTracks
            }
            return nil
        }
    }
    
    var selectedTracks: [NSObject]? {
        get {
            if let theTracks = tracks {
                var theSelectedTracks = [NSObject]()
                let theIndexSet = self.tracksListTableView.selectedRowIndexes
                for theIndex in theIndexSet {
                    theSelectedTracks.append(theTracks[theIndex])
                }
                return theSelectedTracks
            }
            return nil
        }
    }
    
    func removeTracks(theTracksToRemove: [NSObject]) {
        /*var theTracks: [NSObject] = tracks!
         for theTrackToRemove in theTracksToRemove {
         let theIndex: Int = theTracks.index(of: theTrackToRemove)!
         theTracks.remove(at: theIndex)
         }
         datas = theTracks
         tracksListTableView.reloadData()*/
        //_arrayController.remove(atArrangedObjectIndex: 0)
    }
    
    func removeTracks(theIndexesToRemove: IndexSet) {
        arrayController.remove(atArrangedObjectIndexes: theIndexesToRemove)
        let theTracks = arrayController.arrangedObjects as! [NSObject]
        print("V&G_FW___removeTracks : ", theTracks.count)
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
