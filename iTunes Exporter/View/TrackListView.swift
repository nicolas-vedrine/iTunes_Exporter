//
//  TrackListView.swift
//  iTunes Exporter
//
//  Created by Developer on 14/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class TrackListView: VGBaseNSView, VGLoadableNib, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var theArrayController: NSArrayController!
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var trackListTableView: NSTableView!
    @IBOutlet weak var addDeleteButton: NSButton!
    
    
    private var _trackListType: Int = TrackListType.add.rawValue
    private var _tracksAdded: [Track] = [Track]()
    
    @IBInspectable var trackListType: Int = TrackListType.add.rawValue {
        didSet {
            if let addDeleteButton = self.addDeleteButton {
                addDeleteButton.title = trackListType == TrackListType.add.rawValue ? "+" : "-"
            }
            self._trackListType = trackListType
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        trackListTableView.target = self
        trackListTableView.doubleAction = #selector(_onTableViewDoubleClick(_:))
    }
    
    @objc func _onTableViewDoubleClick(_ sender: AnyObject) {
        if trackListType == TrackListType.add.rawValue {
            _addTracksAction()
        }
    }
    
    func setTracks(theTracks: [Track], add: Bool = false) {
        if !add {
            theArrayController.removeAll()
        }
        let theArrangedObjects: [Track] = theArrayController.arrangedObjects as! [Track]
        var isAdd: Bool = false
        for theTrack in theTracks {
            let theArrangedObjectsFiltered = theArrangedObjects.filter({$0.theITTrack.persistentID == theTrack.theITTrack.persistentID})
            var isBreak: Bool = false
            var isIgnore: Bool = false
            if theArrangedObjectsFiltered.count == 0 || isAdd {
                theArrayController.addObject(theTrack)
            } else {
                let result = _messageBoxResult(theTrack: theTrack)
                switch(result) {
                case NSApplication.ModalResponse.alertFirstButtonReturn:
                    isAdd = true
                    theArrayController.addObject(theTrack)
                case NSApplication.ModalResponse.alertSecondButtonReturn:
                    
                    isBreak = true
                case NSApplication.ModalResponse.alertThirdButtonReturn:
                    isIgnore = true
                default:
                    break
                }
                
                if isBreak {
                    print("V&G_FW___<#name#> : ", "break")
                    break
                }
            }
        }
    }
    
    private func _messageBoxResult(theTrack: Track) -> NSApplication.ModalResponse {
        let alert = NSAlert()
        alert.messageText = "Certains titres sélectionnés font déjà partie de la playlist. Voulez-vous les ajouter ou les ignorer ?"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Ignore")
        let result = alert.runModal()
        return result
    }
    
    @IBAction func addDeleteAction(_ sender: Any) {
        switch _trackListType {
        case TrackListType.add.rawValue:
            _addTracksAction()
        case TrackListType.delete.rawValue:
            _deleteTracksAction()
        default:
            _addTracksAction()
        }
    }
    
    private func _addTracksAction() {
        if trackListTableView.selectedRowIndexes.count > 0 {
            var theSelectedTracks: [Track] = [Track]()
            let theIndexSet = self.trackListTableView.selectedRowIndexes
            let theTracks: [Track] = self.theArrayController.arrangedObjects as! [Track]
            for theIndex in theIndexSet {
                theSelectedTracks.append(theTracks[theIndex])
            }
            NotificationCenter.default.post(name: .TRACKS_ADDED, object: theSelectedTracks)
        }
    }
    
    private func _deleteTracksAction() {
        if trackListTableView.selectedRowIndexes.count > 0 {
            let theIndexSet = self.trackListTableView.selectedRowIndexes
            var theTracks: [Track]
            theTracks = self.theArrayController.arrangedObjects as! [Track]
            for theIndex in theIndexSet {
                self.theArrayController.removeObject(theTracks[theIndex])
            }
            theTracks = self.theArrayController.arrangedObjects as! [Track]
            NotificationCenter.default.post(name: .TRACKS_DELETED, object: theTracks)
        }
    }
    
    var tracks: [Track] {
        get {
            let theTracks: [Track] = theArrayController.arrangedObjects as! [Track]
            return theTracks
        }
    }
    
    
}

extension TrackListView {
    
   /*func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableColumn?.identifier)!.rawValue == "trackNumber" {
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TrackListCell"), owner: self)
            return cell
        }
        return nil
    }*/
    
    /*func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return nil
    }*/
    
}

public enum TrackListType: Int {
    case add = 0
    case delete = 1
}
