//
//  ViewController.swift
//  iTunes Exporter
//
//  Created by Developer on 24/01/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa
import iTunesLibrary

class ViewController: BaseProjectViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
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
    
//    lazy var exportController: NSViewController = {
//        return self.storyboard!.instantiateController(withIdentifier: "ExportController")
//            as! NSViewController
//    }()
    
    private var _lib: ITLibrary?
    private var _thePlaylistsGroups: [PlaylistGroup]?
    private var _theArtistsTree: [Artist]?
    
    private var _theFormResult: [String: Any]?
    private var _theCopyFilesOperationQueue: FileOperationQueue?
    
    override func buildView() {
        do {
            _lib = try ITLibrary(apiVersion: "1.0")
            
            _buildTracks()
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
        let theTracks: [ITLibMediaItem] = notification.object as! [ITLibMediaItem]
        switch notification.name {
        case Notification.Name.TRACKS_ADDED:
            //theAddedTracksListView.setTracks(theTracks: theTracks, add: true)
            theAddedTracksListView.tracks = theTracks
        case Notification.Name.TRACKS_DELETED:
            print("V&G_FW____onTracksAddedDeleted : ", self)
            
        default:
            print("V&G_FW____onTracksAddedDeleted : ", self)
        }
        _updateStatutInfos(theTracks: theTracks)
    }
    
    private func _updateStatutInfos(theTracks: [ITLibMediaItem]? = nil) {
        theStatutInfosLabel.stringValue = "Pas d'éléments dans la file d'attente."
        if let theTracks = theTracks {
            if theTracks.count > 0 {
                let statutInfos = iTunesModel.getStatutInfos(theTracks: theTracks)
                var theStr = statutInfos.count.toFormattedNumber() + " morceaux mis en file, "
                theStr += "durée totale " + Int(statutInfos.duration / 1000).toFormattedDuration() + ", "
                theStr += statutInfos.size.toMegaBytes()
                theStatutInfosLabel.stringValue = theStr
            }
        }
    }
    
    private func _addData() {
        if let lib = _lib {
            _addPlaylists(lib: lib)
            //_addArtists(lib: lib)
        }
    }
    
    private func _buildTracks() {
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
        let playlists = iTunesModel.getMusicPlaylists(lib: lib)
        let thePlaylistsTree = iTunesModel.getPlaylistsTree(theITPlaylists: playlists, theLenght: playlists.count)
        if _thePlaylistsGroups == nil {
            _thePlaylistsGroups = iTunesModel.getPlaylistsGroups(thePlaylists: thePlaylistsTree)
        }
        theTreeController.content = _thePlaylistsGroups
        //let item = theOutlineView.
        self.theOutlineView.expandItem(nil, expandChildren: true)
        theSegmentedControl.selectedSegment = 0
        
        let thePlaylistsTreeCopy: [Playlist] = NSArray(array: thePlaylistsTree, copyItems: false) as! [Playlist]
        let theFlattenPlaylist = iTunesModel.getFlattenPlaylistsTree(theList: thePlaylistsTreeCopy, isDistinguishedKind: true, theSeparator: "")
        let theMusicBoxPlaylists = theFlattenPlaylist.filter({($0.name?.lowercased().contains("music box"))!})
        let theMusicBoxPlaylist = theMusicBoxPlaylists[0]
        thePlaylistTracksListView.tracks = theMusicBoxPlaylist.theITPlaylist.items
    }
    
    private func _addArtists(lib: ITLibrary) {
        let artistTreeLoadingObserver = NotificationCenter.default.addObserver(forName: Notification.Name.ARTIST_TREE_LOADING, object: nil, queue: nil) { (notification) in
            self._onArtistTreeLoading(notification: notification)
        }
        
        let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong})
        //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot")})
        if _theArtistsTree == nil {
            _theArtistsTree = iTunesModel.getArtistsTree(theITTracks: theITTracks, theLenght: theITTracks.count)
            //let theArtistsName = iTunesModel.getAllArtistNames(theITTracks: theITTracks)
            //theTreeController.content = theArtistsName
        }
        theSegmentedControl.selectedSegment = 1
        NotificationCenter.default.removeObserver(artistTreeLoadingObserver)
    }
    
    private func _onArtistTreeLoading(notification: Notification) {
        let artistTreeObject = notification.object as! ArtistTreeObject
        //print("V&G_Project___<#name#> : ", artistTreeObject.track?.artist)
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
            if theSegmentedControl.selectedSegment == 0 {
                _addPlaylists(lib: lib)
            } else {
                _addArtists(lib: lib)
            }
        }
    }
    
    @IBAction func exportAction(_ sender: Any) {
        let theExportButton: NSButton = sender as! NSButton
        if theAppInfosView.state == AppInfosViewState.playListInfo.rawValue {
            theExportButton.state = NSControl.StateValue.off
            if theAddedTracksListView.tracks!.count > 0 {
                self.performSegue(withIdentifier: NSStoryboardSegue.EXPORT_SEGUE, sender: self)
            }
        } else {
            _theCopyFilesOperationQueue?.cancelAllOperations()
            theExportButton.state = NSControl.StateValue.off
            theAppInfosView.state = AppInfosViewState.playListInfo.rawValue
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
        //theMenuBox.su
        
        //let exportToArray: [URL] = formResult[FormItemCode.exportTo.rawValue] as! [URL]
        let exportTo: URL = formResult[FormItemCode.exportTo.rawValue] as! URL
        let theChosenIfFileAlreadyExistsType: IfFileAlreadyExistsType = formResult[FormItemCode.ifAlreadyExists.rawValue] as! IfFileAlreadyExistsType
        let theFileNameType: iTunesExportFileNameType = formResult[FormItemCode.fileName.rawValue] as! iTunesExportFileNameType
        for i in 0...theTracksList!.count - 1 {
            let theTrack: ITLibMediaItem = theTracksList![i] as! ITLibMediaItem
            let file: URL = theTrack.location!
            let theSourcePathStr: String = file.path
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
        self.theAppInfosView.state = AppInfosViewState.playListInfo.rawValue
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
                print("V&G_Project___observeValue Operation.FINISHED : ", self, theCopyFileOperation.index, theCopyFileOperation.srcPath)
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

extension ViewController {
    
    func isHeader(item: Any) -> Bool {
        if let item = item as? NSTreeNode {
            return !(item.representedObject is Playlist)
        } else {
            return !(item is Playlist)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        //print("V&G_Project___<#name#> : ", isHeader(item: item))
        var cellID:String
        let treeNode = item as! NSTreeNode
        if isHeader(item: item) {
            cellID = "HeaderCell"
            let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: self)
            return cell
        } else {
            cellID = "DataCell"
            let pl = treeNode.representedObject as! Playlist
            let cell: PlaylistTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellID), owner: self) as! PlaylistTableCellView
            cell.buildCell(thePlaylist: pl)
            return cell
        }
    }
    
    /*func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        print("V&G_FW___<#name#> : ", "isItemExpandable")
        switch item {
        case let playlistGroup as PlaylistGroup:
            return (playlistGroup.children.count > 0) ? true : false
        case let playlist as Playlist:
            if playlist.isFolder && playlist.children!.count > 0 {
                return true
            } else {
                return false
            }
        default:
            return false
        }
    }*/
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        print("V&G_FW___<#name#> : ", item)
        
        if let item = item as? NSTreeNode {
            if item.representedObject is PlaylistGroup {
                return true
            } else if item.representedObject is Playlist {
                let thePlaylist  = item.representedObject as! Playlist
                if thePlaylist.isFolder && (thePlaylist.children?.count)! > 0 {
                    return true
                }else{
                    return false
                }
            } else if item.representedObject is Artist {
                //let theArtist = item.representedObject as! Artist
                return true
            }
        }
        return false
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is PlaylistGroup
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
            if let thePlaylist = theNode.representedObject as? Playlist {
                let theITTracks = thePlaylist.theITPlaylist.items
                let theITSortKind = ITSortKind.artistAndThenAlbum
                let theITTracksSorted = theITTracks.sorted(by: {iTunesModel.sortITTrack(ITTrack1: $0, ITTrack2: $1, kind: theITSortKind)})
                self.thePlaylistTracksListView.tracks = theITTracksSorted
                //print("V&G_Project___outlineViewSelectionDidChange : ", self, thePlaylistTracksListView.tracks)
                /*self.theAppInfosView.setPlaylistDuration(duration: thePlaylist.duration)
                self.theAppInfosView.setCountItems(countItems: thePlaylist.count)
                self.theAppInfosView.setPlaylistName(playlistName: thePlaylist.name!)
                self.theAppInfosView.setSize(size: thePlaylist.size)*/
            }
        }
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
