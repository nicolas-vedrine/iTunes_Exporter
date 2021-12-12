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
    private var _filters: [Int:FilterType] = [Int:FilterType]()
    private var _currentFilter: FilterType?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override var isEnabled: Bool {
        set {
            _isEnabled = newValue
            addDeleteButton.isEnabled = _isEnabled
        }
        get {
            return _isEnabled
        }
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
        
        _buildMenu()
        
        initView()
        
        //searchField.bind(.predicate, to: arrayController, withKeyPath: NSBindingName.filterPredicate.rawValue, options: [.predicateFormat: "title CONTAINS[cd] %@ OR artist.name CONTAINS[cd] $value"])
        //searchField.bind(.predicate, to: arrayController, withKeyPath: NSBindingName.filterPredicate.rawValue, options: [.predicateFormat: "(title contains[cd] $value) OR (artist.name CONTAINS[cd] $value)"])
       // searchField.bind(.predicate, to: arrayController, withKeyPath: NSBindingName.filterPredicate.rawValue, options: [.predicateFormat: "(title contains[cd] $value) OR (artist.name CONTAINS[cd] $value)"])
       // let predicate = searchField.predi
        
        
        //searchField.bind(.predicate, to: arrayController, withKeyPath: NSBindingName.filterPredicate.rawValue, options: nil)
        
        
    }
    
    private func _buildMenu() {
        let theMenu = NSMenu(title: "Filters")
        let theAll = FilterType(title: "ALL", tag: FilterType.FilterListType.ALL.rawValue, field: "")
        let theArtist = FilterType(title: "artist", tag: FilterType.FilterListType.artist.rawValue, field: FilterType.artistField)
        let theTitle = FilterType(title: "title", tag: FilterType.FilterListType.title.rawValue, field: FilterType.titleField)
        let theAlbum = FilterType(title: "album", tag: FilterType.FilterListType.album.rawValue, field: FilterType.albumField)
        _filters[FilterType.FilterListType.ALL.rawValue] = theAll
        _filters[FilterType.FilterListType.artist.rawValue] = theArtist
        _filters[FilterType.FilterListType.title.rawValue] = theTitle
        _filters[FilterType.FilterListType.album.rawValue] = theAlbum
        _currentFilter = theAll
        
        for n in 0..<_filters.count {
            let theFilter = _filters[n]
            let theMenuItem = NSMenuItem(title: theFilter!.title, action: #selector(self._onSearchMenuItemClick), keyEquivalent: "")
            theMenuItem.tag = theFilter!.tag
            theMenuItem.target = self
            theMenu.addItem(theMenuItem)
            if theFilter!.tag == FilterType.FilterListType.ALL.rawValue {
                theMenu.addItem( NSMenuItem.separator() )
            }
        }
        
        searchField.searchMenuTemplate = theMenu
    }
    
    @objc private func _onSearchMenuItemClick(_ sender: NSMenuItem) {
        print("V&G_Project_____onSearchMenuItemClick : ", sender.tag)
        _currentFilter = _filters[sender.tag]
        if searchField.stringValue != "" {
            //_filterTracks(str: searchField.stringValue)
        }
        _filterTracks(str: searchField.stringValue)
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
                    var theTracks = [ITLibMediaItem]() // TODO >>> voir pour optimisation...
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
        if _trackListType == TrackListType.add.rawValue {
            _addTracksAction()
        } else {
            _deleteTracksAction()
        }
    }
    
    private func _addTracksAction() {
        if tracksListTableView.selectedRowIndexes.count > 0 && _isEnabled {
            NotificationCenter.default.post(name: .TRACKS_ADDED, object: selectedTracks)
        }
    }
    
    private func _deleteTracksAction() {
        let theIndexSet = self.tracksListTableView.selectedRowIndexes
        removeTracks(theIndexesToRemove: theIndexSet)
    }    
    
    private func _filterTracks(str: String) {
        if str.count == 0 {
            resetFilter()
            return
        }
        var thePredicates = [NSPredicate]()
        let theArtistPredicate = NSPredicate(format: FilterType.format, FilterType.artistField, str)
        let theTitlePredicate = NSPredicate(format: FilterType.format, FilterType.titleField, str)
        let theAlbumPredicate = NSPredicate(format: FilterType.format, FilterType.albumField, str)
        
        if(_currentFilter?.tag == FilterType.FilterListType.ALL.rawValue){
            thePredicates.append(theArtistPredicate)
            thePredicates.append(theTitlePredicate)
            thePredicates.append(theAlbumPredicate)
        }else if(_currentFilter?.tag == FilterType.FilterListType.artist.rawValue){
            thePredicates.append(theArtistPredicate)
        }else if(_currentFilter?.tag == FilterType.FilterListType.album.rawValue){
            thePredicates.append(theAlbumPredicate)
        }else if(_currentFilter?.tag == FilterType.FilterListType.title.rawValue){
            thePredicates.append(theTitlePredicate)
        }
        
        let theCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: thePredicates)
        arrayController.filterPredicate = theCompoundPredicate
        
        print("V&G_Project____filterTracks : ", arrayController.filterPredicate?.predicateFormat)
    }
    
    func resetFilter() {
        searchField.stringValue = ""
        arrayController.filterPredicate = nil
    }
    
    
}

extension TrackListView {
    
    override func numberOfRows(in tableView: NSTableView) -> Int {
        super.numberOfRows(in: tableView)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let theTableView: NSTableView = notification.object as! NSTableView
        //let selectedIndexes: IndexSet = theTableView.selectedRow
        let theTracks: [NSObject] = arrayController.arrangedObjects as! [NSObject]
        let theTrack: ITLibMediaItem = theTracks[theTableView.selectedRow] as! ITLibMediaItem
        //print("V&G_Project___<#name#> : ", theTrack.artist?.name)
        //dump(theTrack)
    }
    
}

extension TrackListView: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("V&G_Project___TrackListView searchFieldDidStartSearching : ", self)
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("V&G_Project___TrackListView searchFieldDidEndSearching : ", self, sender.stringValue)
        //_filterTracks(str: "") no need to call the func because it is already called in the controlTextDidChange
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let theTextField = obj.object as! NSTextField
        let theStr = theTextField.stringValue
        let theTracks: [NSObject] = arrayController.arrangedObjects as! [NSObject]
        _filterTracks(str: theStr)
    }
}

public enum TrackListType: Int {
    case add = 0
    case delete = 1
}

struct FilterType {
    var title: String
    var tag: Int
    var field: String
    
    static let format = "%K CONTAINS[cd] %@"
    
    static let titleField = "title"
    static let artistField = "artist.name"
    static let albumField = "album.title"
    
    enum FilterListType: Int {
        case ALL = 0
        case title = 1
        case artist = 2
        case album = 3
    }
    
    /*init(title: String, index: Int, format: String) {
        self.title = title
        self.index = index
    }*/
}
