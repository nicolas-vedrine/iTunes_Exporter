//
//  ViewController.swift
//  iTunes Exporter
//
//  Created by Developer on 24/01/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa
import iTunesLibrary

class ViewController: BaseProjectViewController {
    
    @IBOutlet weak var theSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var theAddedTracksListView: TrackListView!
    @IBOutlet weak var thePlaylistTracksListView: TrackListView!
    @IBOutlet var theArrayController: NSArrayController!
    @IBOutlet var theTreeController: NSTreeController!
    @IBOutlet weak var theOutlineView: NSOutlineView!
    @IBOutlet weak var theExportButton: NSButton!
    @IBOutlet weak var theStatutInfosLabel: NSTextField!
    @IBOutlet weak var theAppInfosView: AppInfosView!
    @IBOutlet weak var theMenuBox: NSBox!
    @IBOutlet weak var theSearchField: NSSearchField!
    
    //    lazy var exportController: NSViewController = {
    //        return self.storyboard!.instantiateController(withIdentifier: "ExportController")
    //            as! NSViewController
    //    }()
    
    private var _lib: ITLibrary?
    private var _thePlaylistsGroup: [NodeGroup]?
    private var _theArtistsGroup: [NodeGroup]?
    //private var _theArtistsTree: [Artist]?
    
    private var _theFormResult: [String: Any]?
    private var _theCopyFilesOperationQueue: FileOperationQueue?
    
    override func buildView() {
        do {
            _lib = try ITLibrary(apiVersion: "1.0")
            
            _buildColumns()
            _addData()
        } catch let error {
            print("V&G_Project___buildView : ", error)
        }
        _updateStatutInfos()
        super.buildView()
    }
    
    override func addObservers() {
        let tracksAddedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.TRACKS_ADDED, object: nil, queue: nil) { (notification) in
            self._onTracksAddedDeleted(notification: notification)
        }
        
        let tracksDeletedObserver = NotificationCenter.default.addObserver(forName: Notification.Name.TRACKS_DELETED, object: nil, queue: nil) { (notification) in
            self._onTracksAddedDeleted(notification: notification)
        }
        
        observers.append(tracksAddedObserver)
        observers.append(tracksDeletedObserver)
        
        super.addObservers()
    }
    
    private func _onTracksAddedDeleted(notification: Notification) {
        print("V&G_Project____onTracksAddedDeleted : ", notification.name)
        let theTracks: [ITLibMediaItem] = notification.object as! [ITLibMediaItem]
        switch notification.name {
        case Notification.Name.TRACKS_ADDED:
            theAddedTracksListView.tracks = theTracks
        case Notification.Name.TRACKS_DELETED:
            print("V&G_FW____onTracksAddedDeleted : ", self)
        default:
            print("V&G_FW____onTracksAddedDeleted : ", self)
        }
        _updateStatutInfos()
    }
    
    private func _updateStatutInfos() {
        theStatutInfosLabel.stringValue = "Pas d'éléments dans la file d'attente."
        let theAddedTracks: [ITLibMediaItem] = theAddedTracksListView.tracks as! [ITLibMediaItem]
        let theCount: Int = theAddedTracks.count
        if theCount > 0 {
            let statutInfos = iTunesModel.getStatutInfos(theTracks: theAddedTracks)
            var theStr = theAddedTracks.count.toFormattedNumber() + " morceaux mis en file, "
            theStr += "durée totale " + Int(statutInfos.duration / 1000).toFormattedDuration(unitsStyle: .abbreviated) + ", "
            theStr += statutInfos.size.toMegaBytes()
            theStatutInfosLabel.stringValue = theStr
        }
    }
    
    private func _addData() {
        if let lib = _lib {
            //_addPlaylists(lib: lib)
            _addArtists(lib: lib)
            
            if(IS_DEBUG_MODE) {
                /*let theStr = "music"
                theSearchField.stringValue = theStr
                _search(str: theStr)*/
            }
            
            //thePlaylistsSearchField.bind(.predicate, to: theTreeController, withKeyPath: NSBindingName.filterPredicate.rawValue, options: [.predicateFormat: "(name contains[cd] $value)"])
        }
    }
    
    private func _buildColumns() {
        let trackNumber = ColumnsListStruct(title: "Track Number", id: TableColumnID.trackNumberTableColumnID)
        let title = ColumnsListStruct(title: "Title", id: TableColumnID.titleTableColumnID)
        let artist = ColumnsListStruct(title: "Artist", id: TableColumnID.artistTableColumnID)
        let album = ColumnsListStruct(title: "Album", id: TableColumnID.albumTableColumnID)
        let totalTime = ColumnsListStruct(title: "Total Time", id: TableColumnID.totalTimeTableColumnID)
        let location = ColumnsListStruct(title: "Emplacement", id: TableColumnID.locationTableColumnID)
        
        let columnsList: [ColumnsListStruct] = [trackNumber, title, artist, album, totalTime, location]
        theAddedTracksListView.buildColumns(columnsList: columnsList)
        thePlaylistTracksListView.buildColumns(columnsList: columnsList)
    }
    
    private func _addPlaylists(lib: ITLibrary) {
        let theITPlaylists = iTunesModel.getMusicPlaylists(lib: lib)
        let theRootITPlaylists = theITPlaylists.filter({ $0.parentID == nil })
        let thePlaylistsTree = iTunesModel.getPlaylistsTree(theLevelITPlaylists: theRootITPlaylists, theITPlaylists: theITPlaylists)
        if _thePlaylistsGroup == nil {
            _thePlaylistsGroup = iTunesModel.getPlaylistsGroups(playlists: thePlaylistsTree)
        }
        _resetTree()
        //theSegmentedControl.selectedSegment = 0
        
        theSearchField.target = self
        if #available(macOS 10.11, *) {
            theSearchField.delegate = self
        } else {
            // Fallback on earlier versions
        }
        
        // remplissage auto de tableaux
        if IS_DEBUG_MODE {
            /*let thePlaylistsTreeCopy: [Playlist] = NSArray(array: thePlaylistsTree, copyItems: false) as! [Playlist]
            let theFlattenPlaylist = iTunesModel.getFlattenPlaylistsTree(theList: thePlaylistsTreeCopy, isIndent: false, theSeparator: "")
            let theMusicBoxPlaylists = theFlattenPlaylist.filter({($0.name?.lowercased().contains("music box"))!})
            let thePlaylistTest = theMusicBoxPlaylists[0]
            thePlaylistTracksListView.tracks = thePlaylistTest.theITPlaylist.items
            
            let thePlaylistTestTracks: [ITLibMediaItem] = (thePlaylistTracksListView.tracks! as? [ITLibMediaItem])!
            let thePlaylistTestTracksShuffled = thePlaylistTestTracks.shuffled()
            //let theRandomInt = Int.random(in: 0..<thePlaylistTestTracks.count - 1)
            let theRandomInt = Int.random(in: 2..<10)
            var theTracksToAdd: [ITLibMediaItem] = [ITLibMediaItem]()
            for n in 0...theRandomInt {
                let theTrackToAdd: ITLibMediaItem = thePlaylistTestTracksShuffled[n]
                theTracksToAdd.append(theTrackToAdd)
            }
            theAddedTracksListView.tracks = theTracksToAdd*/
        }
    }
    
    private func _addArtists(lib: ITLibrary) {
        let artistTreeLoadingObserver = NotificationCenter.default.addObserver(forName: Notification.Name.ARTIST_TREE_LOADING, object: nil, queue: nil) { (notification) in
            self._onArtistTreeLoading(notification: notification)
        }
        
        
        //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot")})
        //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot" || $0.artist?.name == nil)})
        
        if _theArtistsGroup == nil {
            let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong})
            //let theITTracksNoCompilation = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && !$0.album.isCompilation })
            let theITTracksCompilations = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && $0.album.isCompilation })
            
            let theArtistsTree = iTunesModel.getArtistsTree(ITTracks: theITTracks)
            let theCompilationsTree = iTunesModel.getAlbumsTree(ITTracks: theITTracksCompilations)
            var theITNodesList = [[ITNode]]()
            theITNodesList.append(theArtistsTree)
            theITNodesList.append(theCompilationsTree)
            _theArtistsGroup = iTunesModel.getArtistsGroups(ITNodesList: theITNodesList)
        }
        theTreeController.content = _theArtistsGroup
        theSegmentedControl.selectedSegment = 1
        _resetTree()
        NotificationCenter.default.removeObserver(artistTreeLoadingObserver)
    }
    
    private func _onArtistTreeLoading(notification: Notification) {
        let artistTreeObject = notification.object as! ArtistTreeObject
        theAppInfosView.setProgress(current: Double(artistTreeObject.current!), total: Double(artistTreeObject.total!))
    }
    
    private func _filterArtist(theTracks: [ITLibMediaItem], theArtistName: String) -> [ITLibMediaItem] {
        var theSearch: [ITLibMediaItem] = [ITLibMediaItem]()
        for track in theTracks {
            if (track.artist?.name != nil && (track.artist?.name?.lowercased().contains(theArtistName))!) {
                theSearch.append(track)
            }
        }
        return theSearch
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        let theSegmentedControl = sender as! NSSegmentedControl
        print("V&G_FW___theSeg : ", theSegmentedControl.selectedSegment)
        if let lib = _lib {
            switch theSegmentedControl.selectedSegment {
            case TreeMode.playlists.rawValue:
                _addPlaylists(lib: lib)
            case TreeMode.artists.rawValue:
                _addArtists(lib: lib)
            default:
                _addPlaylists(lib: lib)
            }
        }
    }
    
    @IBAction func exportAction(_ sender: Any) {
        let theExportButton: NSButton = sender as! NSButton
        if theAppInfosView.state == AppInfosViewState.playlistInfo.rawValue {
            theExportButton.state = NSControl.StateValue.off
            if theAddedTracksListView.tracks!.count > 0 {
                self.performSegue(withIdentifier: NSStoryboardSegue.EXPORT_SEGUE, sender: self)
            }
        } else {
            _theCopyFilesOperationQueue?.cancelAllOperations()
            theExportButton.state = NSControl.StateValue.off
            theAppInfosView.state = AppInfosViewState.playlistInfo.rawValue
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == NSStoryboardSegue.EXPORT_SEGUE) {
            if let exportVC = segue.destinationController as? ExportController {
                exportVC.data = theAddedTracksListView.tracks
                exportVC.onValidateForm = { (formResult: [String: Any]) -> () in
                    self._theFormResult = formResult
                    self._exportFiles(formResult: formResult)
                }
            }
        }
    }
    
    private func _exportFiles(formResult: [String: Any]) {
        print("V&G_Project____exportFiles : ", formResult)
        _theCopyFilesOperationQueue = FileOperationQueue()
        _theCopyFilesOperationQueue?.isSuspended = true
        _theCopyFilesOperationQueue?.name = "exportFiles"
        _theCopyFilesOperationQueue?.qualityOfService = .userInitiated
        _theCopyFilesOperationQueue?.maxConcurrentOperationCount = 1
        let fm: FileManager = FileManager.default
        let theTracksList = theAddedTracksListView.tracks
        theAppInfosView.state = AppInfosViewState.exporting.rawValue
        theAppInfosView.setStatus(theStatus: AppInfosView.exportingStatus)
        theExportButton.state = NSControl.StateValue.on
        
        let exportTo: URL = formResult[FormItemCode.exportTo.rawValue] as! URL
        let theChosenIfFileAlreadyExistsType: IfFileAlreadyExistsType = formResult[FormItemCode.ifAlreadyExists.rawValue] as! IfFileAlreadyExistsType
        let theFileNameType: iTunesExportFileNameType = formResult[FormItemCode.fileName.rawValue] as! iTunesExportFileNameType
        for i in 0...theTracksList!.count - 1 {
            let theTrack: ITLibMediaItem = theTracksList![i] as! ITLibMediaItem
            let theFile: URL = theTrack.location!
            let theSourcePathStr: String = theFile.path
            let theDestinationPattern: String = iTunesModel.getDestinationPattern(theITTrack: theTrack, fileNameType: theFileNameType)
            let theDestinationPathStr: String = exportTo.path + "/" + theDestinationPattern
            let theCopyFileOperation: FileOperation = FileOperation(fileManager: fm, srcPath: theSourcePathStr, dstPath: theDestinationPathStr, ifFileAlreadyExistsType: theChosenIfFileAlreadyExistsType)
            theCopyFileOperation.index = i
            theCopyFileOperation.addObserver(self, forKeyPath: Operation.FINISHED, options: .new, context: nil)
            theCopyFileOperation.addObserver(self, forKeyPath: Operation.EXECUTING, options: .new, context: nil)
            theCopyFileOperation.addObserver(self, forKeyPath: Operation.CANCELLED, options: .new, context: nil)
            theCopyFileOperation.operationQueue = _theCopyFilesOperationQueue
            _theCopyFilesOperationQueue!.addOperation(theCopyFileOperation)
        }
        _theCopyFilesOperationQueue?.isSuspended = false
    }
    
}

extension ViewController {
    
    private func _reset() {
        self.theExportButton.state = NSControl.StateValue.off
        self.theAppInfosView.state = AppInfosViewState.playlistInfo.rawValue
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is FileOperation {
            let key = keyPath!
            let theCopyFileOperation: FileOperation = object as! FileOperation
            let operationQueue: FileOperationQueue = theCopyFileOperation.operationQueue! as! FileOperationQueue
            let index: Double = Double(theCopyFileOperation.index!)
            let total: Double = Double(operationQueue.count)
            let current: Int = Int(index) + 1
            let theSrcPathURL: URL = URL(fileURLWithPath: theCopyFileOperation.srcPath)
            let theDstPathURL: URL = URL(fileURLWithPath: theCopyFileOperation.dstPath)
            let isMainThread: Bool = Thread.isMainThread
            print("V&G_Project___observeValue key : ", self, isMainThread, key, theCopyFileOperation.dstPath)
            
            switch key {
            case Operation.FINISHED:
                print("V&G_Project___observeValue Operation.FINISHED : ", self, theCopyFileOperation.index!, theCopyFileOperation.srcPath)
                DispatchQueue.main.async { [unowned self] in
                    if !(self._theCopyFilesOperationQueue?.isCancelled)! {
                        self.theAppInfosView.setProgress(current: Double(current), total: total)
                        
                        if index == total - 1 {
                            self._reset()
                            self._notif()
                        }
                    }
                }
                theCopyFileOperation.removeObserver(self, forKeyPath: Operation.FINISHED, context: nil)
                theCopyFileOperation.removeObserver(self, forKeyPath: Operation.CANCELLED, context: nil)
                print("V&G_Project___observeValue Operation.FINISHED : ", self, theCopyFileOperation.isCancelled)
            case Operation.EXECUTING:
                if theCopyFileOperation.ifFileAlreadyExistsType == IfFileAlreadyExistsType.ask {
                    DispatchQueue.main.async { [unowned self] in
                        //let theData = self._ask(copyFileOperation: theCopyFileOperation)
                        let theData = IfFileAlreadyExistsType.overwrite
                        theCopyFileOperation.ifFileAlreadyExistsType = theData
                        theCopyFileOperation.main()
                    }
                } else {
                    DispatchQueue.main.sync { [unowned self] in
                        print("V&G_Project___observeValue Operation.FINISHED statut : ", _theCopyFilesOperationQueue?.isCancelled, self)
                        if !(_theCopyFilesOperationQueue?.isCancelled)! {
                            let theStr: String = "copy of : " +  String(current) + " / " + String(Int(total)) + " - " + theSrcPathURL.getName()! + " to " + theDstPathURL.path
                            self.theAppInfosView.setTrackName(theTrackName: theStr)
                        }
                    }
                }
                theCopyFileOperation.removeObserver(self, forKeyPath: Operation.EXECUTING, context: nil)
            case Operation.CANCELLED:
                print("V&G_Project___observeValue cancelling : ", self, theCopyFileOperation.index, _theCopyFilesOperationQueue?.count, theCopyFileOperation.isExecuting)
            default:
                print("V&G_Project___observeValue default : ", self)
            }
        }
    }
    
    private func _ask(copyFileOperation: FileOperation) -> IfFileAlreadyExistsType {
        let theSourceURL: URL = URL(fileURLWithPath: copyFileOperation.srcPath)
        let theDestinationFolderURL: URL = URL(fileURLWithPath: copyFileOperation.dstPath)
        let alert = NSAlert()
        alert.messageText = "Le fichier " + theSourceURL.getName()! + " already exists in " + theDestinationFolderURL.getName()!
        let theIfAlreadyExistsDataSource = DataSources.getIfAlreadyExistsDataSource()
        for i in 0...theIfAlreadyExistsDataSource.count - 1 {
            let theItem: VGBaseDataForm = theIfAlreadyExistsDataSource[i]
            let theData: IfFileAlreadyExistsType = theItem.data as! IfFileAlreadyExistsType
            if theData != IfFileAlreadyExistsType.ask {
                let btn = alert.addButton(withTitle: theItem.label)
            }
        }
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "remember..."
        let result = alert.runModal()
        
        let isChecked: Bool = alert.suppressionButton?.state == NSControl.StateValue.on ? true : false
        print("V&G_Project____ask : ", isChecked, result)
        let theIndex: Int = result.rawValue - 1000
        let theObj: VGBaseDataForm = theIfAlreadyExistsDataSource[theIndex]
        let theData: IfFileAlreadyExistsType = theObj.data as! IfFileAlreadyExistsType
        if isChecked {
            for i in 0...(_theCopyFilesOperationQueue?.operationCount)! - 1 {
                let theCopyFileOperation: FileOperation = _theCopyFilesOperationQueue?.operations[i] as! FileOperation
                theCopyFileOperation.ifFileAlreadyExistsType = theData
            }
        }
        return theData
    }
    
}

extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var cellID:String
        let theTreeNode = item as! NSTreeNode
        let theTreeNodeObject = theTreeNode.representedObject as! NSObject
        if theTreeNodeObject is ITNode {
            cellID = "DataCell"
            let theCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: self) as! TreeTableCellView
            theCell.buildCell(node: theTreeNodeObject)
            return theCell
        } else {
            cellID = "HeaderCell"
            let theCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: self)
            return theCell
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        print("V&G_Project___outlineView : ", self) // TODO
        if let item = item as? NSTreeNode {
            if item.representedObject is NodeGroup {
                return true
            } else if item.representedObject is Playlist {
                let thePlaylist  = item.representedObject as! Playlist
                print("V&G_Project___outlineView : ", "theSearchField.stringValue.count", theSearchField.stringValue.count)
                if thePlaylist.isFolder && (thePlaylist.children!.count > 0) && (theSearchField.stringValue.count == 0) {
                    return true
                }else{
                    return false
                }
            } else if item.representedObject is Artist {
                return true
            }
        }
        return false
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is NodeGroup
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        //1
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        //2
        let selectedIndex = outlineView.selectedRow
        if let theNode = outlineView.item(atRow: selectedIndex) as? NSTreeNode {
            //3
            let theNodeObject = theNode.representedObject
            if let thePlaylist = theNodeObject as? Playlist {
                let theITTracks = thePlaylist.theITPlaylist.items
                let theITSortKind = ITSortKind.artistAndThenAlbum
                let theITTracksSorted = theITTracks.sorted(by: {iTunesModel.sortITTrack(ITTrack1: $0, ITTrack2: $1, kind: theITSortKind)})
                self.thePlaylistTracksListView.tracks = theITTracksSorted
                self.theAppInfosView.setDuration(duration: thePlaylist.duration)
                self.theAppInfosView.setCountItems(countItems: thePlaylist.count)
                self.theAppInfosView.setName(name: thePlaylist.name)
                self.theAppInfosView.setSize(size: thePlaylist.size)
            } else if let theArtist = theNodeObject as? Artist {
                //let theITArtistTracks = _lib!.allMediaItems.filter({$0.mediaKind == .kindSong && $0.artist?.name?.lowercased() == theArtist.name.lowercased()})
                //print(theArtist.getITTracks(ITArtistTracks: theITArtistTracks))
                let theITTracks = theArtist.getITTracks()
                self.thePlaylistTracksListView.tracks = theITTracks
                self.theAppInfosView.setDuration(duration: theArtist.duration)
                self.theAppInfosView.setCountItems(countItems: theITTracks.count)
                self.theAppInfosView.setName(name: theArtist.name)
                self.theAppInfosView.setSize(size: theArtist.size)
            } else if let theAlbum = theNodeObject as? Album {
                let theITTracks = theAlbum.ITTracks
                self.thePlaylistTracksListView.tracks = theITTracks
                self.theAppInfosView.setDuration(duration: theAlbum.duration)
                self.theAppInfosView.setCountItems(countItems: theITTracks.count)
                self.theAppInfosView.setSize(size: theAlbum.size)
            }
        }
    }
    
}

extension ViewController: NSSearchFieldDelegate {
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        print("V&G_Project___TrackListView searchFieldDidStartSearching : ", self)
    }
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        print("V&G_Project___TrackListView searchFieldDidEndSearching : ", self)
        _resetTree()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let theTextField = obj.object as! NSTextField
        let theStr = theTextField.stringValue
        _search(str: theStr)
    }
    
    private func _search(str: String) {
        //thePlaylistsSearchField.sendAction(thePlaylistsSearchField.action, to: thePlaylistsSearchField.target)
        let thePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", str)
        
        
        
        if let thePersonalPlaylistsGroup = _thePlaylistsGroup!.filter({$0.id == iTunesModel.PlaylistsGroupID.allPlaylists.rawValue}).first {
            if let thePersonalPlaylists = thePersonalPlaylistsGroup.children {
                let theFlattenNodes = iTunesModel.getFlattenNodesTree(nodes: thePersonalPlaylists)
                
                _resetSearch(nodes: theFlattenNodes)
                
                if str.count > 0 {
                    let theSearchResults = theFlattenNodes.filter({ $0.name.lowercased().contains(str.lowercased()) })
                    for theNode in theSearchResults {
                        //print("V&G_Project___controlTextDidChange : ", thePersonalPlaylist.name)
                        //thePersonalPlaylist.predicate = thePredicate
                        
                        
                        //print(thePersonalPlaylist.name, "----------")
                        /*if thePlaylist.children.count > 0 {
                            let theResult = thePlaylist.children.flatMap({$0.name})
                            //dump(theResult)
                            //let theResult: [Playlist] = thePersonalPlaylist.children.flatten().compactMap { $0 }
                            //let theNames = theResult.map({$0.name})
                            //print(theResult)
                        }*/
                        
                        
                        if !theNode.isLeaf() {
                            theNode.isSearched = true
                        }
                    }
                    theTreeController.content = theSearchResults
                } else {
                    _resetTree()
                }
            }
        }
    }
    
    private func _resetSearch(nodes: [Node]) {
        /*let theIsSearchedPlaylists = nodes.filter({ $0.isSearched })
        
        for theIsSearchedPlaylist in theIsSearchedPlaylists {
            theIsSearchedPlaylist.isSearched = false
            print("V&G_Project__resetSearch : ", theIsSearchedPlaylist.isSearched, theIsSearchedPlaylist.name)
        }*/
    }
    
    private func _resetTree() {
        switch theSegmentedControl.selectedSegment {
        case TreeMode.playlists.rawValue:
            theTreeController.content = _thePlaylistsGroup
        case TreeMode.artists.rawValue:
            theTreeController.content = _theArtistsGroup
        default:
            theTreeController.content = _thePlaylistsGroup
        }
        self.theOutlineView.expandItem(nil, expandChildren: true)
    }
    
}


extension ViewController: NSUserNotificationCenterDelegate {
    
    private func _notif() {
        let notification = NSUserNotification()
        // All these values are optional
        notification.title = "Test of notification"
        notification.subtitle = "Subtitle of notifications"
        notification.informativeText = "Main informative text"
        notification.actionButtonTitle = "Show in Finder"
        notification.soundName = NSUserNotificationDefaultSoundName
        
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.delegate = self
        
        notificationCenter.deliver(notification)
        print("V&G_Project___showNotification : ", self)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        print("V&G_Project___didActivate : ", self, notification.activationType.rawValue)
        if notification.activationType == .actionButtonClicked {
            let theURL: URL = _theFormResult![FormItemCode.exportTo.rawValue] as! URL
            NSWorkspace.shared.open(theURL)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        print("V&G_Project___didDeliver : ", self, notification)
    }
    
}

enum TreeMode: Int {
    case playlists = 0
    case artists = 1
    case albums = 2
}
