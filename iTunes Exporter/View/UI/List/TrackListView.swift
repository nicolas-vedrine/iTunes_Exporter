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
    @IBOutlet weak var searchField: NSSearchField!
    
    private var _trackListType: Int = TrackListType.add.rawValue
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        tracksListTableView = iTunesExporterTracksListTableView
        
        searchField.target = self
        if #available(macOS 10.11, *) {
            searchField.delegate = self
        } else {
            // Fallback on earlier versions
        }
        
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
    
    // to add and get tracks
    override var tracks: [NSObject]? {
        set {
            if _trackListType == TrackListType.add.rawValue {
                super.tracks = newValue
            } else {
                
                if let datas: [ITLibMediaItem] = tracks as? [ITLibMediaItem] {
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
                
                
                /*if let datas: [ITLibMediaItem] = datas as? [ITLibMediaItem] {
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
                    }*/
                    super.tracks = theTracks
                } else {
                    super.tracks = newValue
                }
            }
            
        }
        get {
            return super.tracks
        }
    }
    
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
        if tracksListTableView.selectedRowIndexes.count > 0 {
            let theSelectedTracks: [NSObject] = selectedTracks!
            //removeTracks(theTracksToRemove: theSelectedTracks)
            let theIndexSet = self.tracksListTableView.selectedRowIndexes
            //tracksListTableView.removeRows(at: theIndexSet, withAnimation: .effectFade)
            removeTracks(theIndexesToRemove: theIndexSet)
            NotificationCenter.default.post(name: .TRACKS_DELETED, object: theSelectedTracks)            
        }
    }    
    
    
}

extension TrackListView {
    
    override func numberOfRows(in tableView: NSTableView) -> Int {
        super.numberOfRows(in: tableView)
    }
    
}

extension TrackListView: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("didStart")
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("didEnd")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let theTextField = obj.object as! NSTextField
        let theStr = theTextField.stringValue
        filterTracks(theStr: theStr)
    }
}

public enum TrackListType: Int {
    case add = 0
    case delete = 1
}
