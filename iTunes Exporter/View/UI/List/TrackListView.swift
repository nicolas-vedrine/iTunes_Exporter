//
//  TrackListView.swift
//  iTunes Exporter
//
//  Created by Developer on 14/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class TrackListView: iTunesTracksListView, VGLoadableNib {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var addDeleteButton: NSButton!
    @IBOutlet weak var iTunesExporterTracksListTableView: NSTableView!
    
    private var _trackListType: Int = TrackListType.add.rawValue
    //private var _tracksAdded: [IT] = [Track]()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        tracksListTableView = iTunesExporterTracksListTableView
        initView()
    }
    
    @IBInspectable var trackListType: Int = TrackListType.add.rawValue {
        didSet {
            if let addDeleteButton = self.addDeleteButton {
                addDeleteButton.title = trackListType == TrackListType.add.rawValue ? "+" : "-"
            }
            self._trackListType = trackListType
        }
    }
    
    @objc override func _onTableViewDoubleClick(_ sender: AnyObject) {
        if trackListType == TrackListType.add.rawValue {
            _addTracksAction()
        }
    }
    
    override var tracks: [NSObject]? {
        set {
            if _trackListType == TrackListType.add.rawValue {
                super.tracks = newValue
            } else {
                if let datas: [ITLibMediaItem] = datas as? [ITLibMediaItem] {
                    var theTracks = [ITLibMediaItem]()
                    for track in datas {
                        theTracks.append(track)
                    }
                    let theTracksToAdd: [ITLibMediaItem] = newValue as! [ITLibMediaItem]
                    var isAdd: Bool = false
                    var isRemembered: Bool = false
                    for theTrackToAdd in theTracksToAdd {
                        let theFilter = theTracks.filter({$0.persistentID == theTrackToAdd.persistentID})
                        var isCanceled: Bool = false
                        var isIgnore: Bool = false
                        if theFilter.count == 0 {
                            theTracks.append(theTrackToAdd)
                        } else {
                            if !isRemembered {
                                let msgBoxResult = _messageBoxResult(theTrack: theTrackToAdd)
                                isRemembered = msgBoxResult.isRemembered
                                switch(msgBoxResult.response) {
                                case NSApplication.ModalResponse.alertFirstButtonReturn:
                                    isAdd = true
                                    theTracks.append(theTrackToAdd)
                                case NSApplication.ModalResponse.alertSecondButtonReturn:
                                    isCanceled = true
                                case NSApplication.ModalResponse.alertThirdButtonReturn:
                                    isIgnore = true
                                    if isRemembered {
                                        isCanceled = true
                                    }
                                default:
                                    break
                                }
                                
                                if isCanceled {
                                    break
                                }
                            } else {
                                if isAdd {
                                    theTracks.append(theTrackToAdd)
                                }
                            }
                        }
                    }
                    super.datas = theTracks
                    tracksListTableView.reloadData()
                    /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        //self!.tracksListTableView.reloadData()
                    }*/
                    
                } else {
                    super.tracks = newValue
                }
                //print("V&G_Project___tracks : ", self, theTracks?.count)
            }
            
        }
        get {
            return super.tracks
        }
    }
    
    /*func setTracks(theTracks: [Track], add: Bool = false) {
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
    }*/
    
    private func _messageBoxResult(theTrack: ITLibMediaItem) -> MessageBoxResult {
        let alert = NSAlert()
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "remember..."
        let trackTitle = iTunesModel.getFormattedTrackName(theITTrack: theTrack, theFormattedTrackNameStyle: .artistNameTrackName)
        alert.messageText = "Le titre \"" + trackTitle + "\" fait déjà parti de la playlist. Voulez-vous l'ajouter ?"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Ignore")
        let result = alert.runModal()
        let isRemembered: Bool = alert.suppressionButton?.state == NSControl.StateValue.on ? true : false
        let msgBoxResult = MessageBoxResult(response: result, isRemembered: isRemembered)
        return msgBoxResult
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
        if tracksListTableView.selectedRowIndexes.count > 0 {
            NotificationCenter.default.post(name: .TRACKS_ADDED, object: selectedTracks)
        }
    }
    
    private func _deleteTracksAction() {
        /*if trackListView.selectedRowIndexes.count > 0 {
            let theIndexSet = self.trackListView.selectedRowIndexes
            var theTracks: [Track]
            theTracks = self.theArrayController.arrangedObjects as! [Track]
            for theIndex in theIndexSet {
                self.theArrayController.removeObject(theTracks[theIndex])
            }
            theTracks = self.theArrayController.arrangedObjects as! [Track]
            NotificationCenter.default.post(name: .TRACKS_DELETED, object: theTracks)
        }*/
    }
    
}

extension TrackListView {
    
    /*override func numberOfRows(in tableView: NSTableView) -> Int {
        return theiTunesTracks?.count ?? 0
    }*/
    
}

public enum TrackListType: Int {
    case add = 0
    case delete = 1
}
