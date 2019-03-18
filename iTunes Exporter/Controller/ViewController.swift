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
    
//    lazy var exportController: NSViewController = {
//        return self.storyboard!.instantiateController(withIdentifier: "ExportController")
//            as! NSViewController
//    }()
    
    private var _lib: ITLibrary?
    private var _thePlaylistsGroups: [PlaylistGroup]?
    private var _theArtistsTree: [Artist]?
    
    override func buildView() {
        do {
            _lib = try ITLibrary(apiVersion: "1.0")
            _addData()
        } catch let error {
            print("V&G_Project___<#name#> : ", error)
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
        let theTracks: [Track] = notification.object as! [Track]
        switch notification.name {
        case Notification.Name.TRACKS_ADDED:
            theAddedTracksListView.setTracks(theTracks: theTracks, add: true)
        case Notification.Name.TRACKS_DELETED:
            print("V&G_FW___<#name#> : ", self)
            
        default:
            print("V&G_FW___<#name#> : ", self)
        }
        _updateStatutInfos(theTracks: theAddedTracksListView.tracks)
    }
    
    private func _updateStatutInfos(theTracks: [Track]? = nil) {
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
        if theAddedTracksListView.tracks.count > 0 {
            self.performSegue(withIdentifier: NSStoryboardSegue.EXPORT_SEGUE, sender: self)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if (segue.identifier == NSStoryboardSegue.EXPORT_SEGUE) {
            if let exportVC = segue.destinationController as? ExportController {
                exportVC.data = theAddedTracksListView.tracks
            }
        }
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
        switch item {
        case let playlistGroup as PlaylistGroup:
            return true
        default:
            return false
        }
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
                self.thePlaylistTracksListView.setTracks(theTracks: thePlaylist.tracks)
                self.theAppInfosView.setPlaylistDuration(duration: thePlaylist.duration)
                self.theAppInfosView.setCountItems(countItems: thePlaylist.count)
                self.theAppInfosView.setPlaylistName(playlistName: thePlaylist.name!)
                self.theAppInfosView.setSize(size: thePlaylist.size)
            }
        }
    }
    
}
