//
//  iTunesObjects.swift
//  Swift-AppleScriptObjC
//
//  Created by Developer on 24/01/2019.
//

import Foundation
import iTunesLibrary

class PlaylistGroup: NSObject {
    
    @objc dynamic var name: String?
    @objc dynamic var children: [Playlist] = [Playlist]()
    var isAllPlaylists: Bool = false
    
    @objc func isLeaf() -> Bool {
        return false
    }
    
    init(name: String, isAllPlaylists: Bool = false) {
        self.name = name
        self.isAllPlaylists = isAllPlaylists
    }
    
}

class ITNodeBase: NSObject {
    
}

class Playlist: ITNodeBase {
    
    @objc dynamic var name: String?
    @objc dynamic var isFolder: Bool = false
    @objc dynamic var isSmart: Bool = false
    @objc dynamic var count: Int = 0
    @objc dynamic var id: NSNumber?
    var kind: ITLibPlaylistKind?
    //@objc dynamic var children: [Playlist]?
    private(set) var theITPlaylist: ITLibPlaylist
    
    //typealias Element = Playlist
    
    var predicate: NSPredicate? {
        didSet {
            _propagatePredicatesAndRefilterChildren()
        }
    }
    
    @objc dynamic var children: [Playlist] = [] {
        didSet {
            _propagatePredicatesAndRefilterChildren()
        }
    }
    
    var duration: Int {
        get {
            var duration: Int = 0
            for theITTrack in theITPlaylist.items {
                duration += theITTrack.totalTime / 1000
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var size: UInt64 = 0
            for theITTrack in theITPlaylist.items {
                size += theITTrack.fileSize
            }
            return size
        }
    }
    
    var tracks: [Track] {
        get {
            return iTunesModel.getTracksFromITTracks(theITTracks: theITPlaylist.items)
        }
    }
    
    /*@objc func isLeaf() -> Bool {
        return !(self.isFolder)
    }*/
    
    @objc private(set) dynamic var isLeaf: Bool = true
    
    init(thePlaylist: ITLibPlaylist) {
        self.name = thePlaylist.name
        self.id = thePlaylist.persistentID
        self.kind = thePlaylist.kind
        self.isFolder = thePlaylist.kind == .folder
        self.count = thePlaylist.items.count
        self.isSmart = kind == .smart
        self.theITPlaylist = thePlaylist
        if isFolder {
            children = [Playlist]()
        }
    }
    
    @objc private(set) dynamic var filteredChildren: [Playlist] = [] {
            didSet {
                count = filteredChildren.count
                isLeaf = filteredChildren.isEmpty
            }
        }
    
    private func _propagatePredicatesAndRefilterChildren() {
        // Propagate the predicate down the child nodes in case either
        // the predicate or the children array changed.
        children.forEach { $0.predicate = predicate }
        
        // Determine the matching leaf nodes.
        let newChildren: [Playlist]
        
        if let predicate = predicate {
            newChildren = children.compactMap { child -> Playlist? in
                if child.isLeaf, !predicate.evaluate(with: child) {
                    return nil
                }
                return child
            }
        } else {
            newChildren = children
        }
        
        // Only actually update the children if the count varies.
        if newChildren.count != filteredChildren.count {
            filteredChildren = newChildren
        }
    }
}

class Artist: ITNodeBase {
    
    @objc dynamic var name: String = ""
    var albums: [Album] = [Album]()
    private var _ITArtist: ITLibArtist
    
    @objc dynamic var children: [Album] {
        get {
            return albums
        }
    }
    
    @objc func isLeaf() -> Bool {
        return false
    }
    
    init(theITArtist: ITLibArtist) {
        if let theName = theITArtist.name {
            self.name = theName
        }
        self._ITArtist = theITArtist
    }
    
    func getAlbum(by name: String) -> Album? {
        for album in albums {
            let theAlbumName = album.name
            if name == theAlbumName {
                return album
            }
        }
        return nil
    }
    
    /*func getITTracks(ITArtistTracks: [ITLibMediaItem]) -> [ITLibMediaItem] {
        let theITTracks = [ITLibMediaItem]()
        for album in albums {
            //let theArtistAlbums = Dictionary(grouping: theAlbumsTracks, by: { $0.album.title?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
            let theITTracksAlbumDic = Dictionary(grouping: ITArtistTracks, by: { $0.album.persistentID })
            print("V&G_Project___getITTracks : ", theITTracksAlbumDic, theITTracksAlbumDic.count)
            print("-----------------")
        }
        return theITTracks
    }*/
    
    /*func getITTracks() -> [ITLibMediaItem] {
        let theTracks = getTracks()
        let theITTracks = theTracks.map({$0.theITTrack})
        return theITTracks
    }*/
    
    func getTracks() -> [Track] {
        var theTrack = [Track]()
        for album in albums {
            for track in album.tracks {
                theTrack.append(track)
            }
        }
        return theTrack
    }
    
    func getITTracks() -> [ITLibMediaItem] {
        var theITTracks = [ITLibMediaItem]()
        for album in albums {
            for ITTrack in album.ITTracks {
                theITTracks.append(ITTrack)
            }
        }
        return theITTracks
    }
    
    var duration: Int {
        get {
            var duration: Int = 0
            for theITTrack in getITTracks() {
                duration += theITTrack.totalTime / 1000
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var size: UInt64 = 0
            for theITTrack in getITTracks() {
                size += theITTrack.fileSize
            }
            return size
        }
    }
    
}

class Album: ITNodeBase {
    
    @objc dynamic var name = ""
    @objc dynamic var tracks = [Track]()
    var ITTracks = [ITLibMediaItem]()
    private var _ITAlbum: ITLibAlbum?
    
    @objc func isLeaf() -> Bool {
        return true
    }
    
    init(theITAlbum: ITLibAlbum){
        if let theName = theITAlbum.title {
            self.name = theName
        }
        self._ITAlbum = theITAlbum
    }
    
    /*func getITTracks() -> [ITLibMediaItem] {
        return tracks.map({ $0.theITTrack })
    }*/
    
    var ITAlbum: ITLibAlbum {
        get {
            return _ITAlbum!
        }
    }
    
    var duration: Int {
        get {
            var duration: Int = 0
            for theITTrack in ITTracks {
                duration += theITTrack.totalTime / 1000
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var size: UInt64 = 0
            for theITTrack in ITTracks {
                size += theITTrack.fileSize
            }
            return size
        }
    }
    
}

class Track: NSObject {
    
    @objc dynamic var artist: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var album: String = ""
    @objc dynamic var duration: Int = 0
    @objc dynamic var size: UInt64 = 0
    @objc dynamic var location: URL?
    private(set) var theITTrack: ITLibMediaItem
    
    init(theITTrack: ITLibMediaItem) {
        self.artist = iTunesModel.getArtistName(theITTrack: theITTrack)
        self.name = theITTrack.title
        if let theAlbumName = theITTrack.album.title {
            self.album = theAlbumName
        }
        self.duration = theITTrack.totalTime
        self.size = theITTrack.fileSize
        self.location = theITTrack.location
        self.theITTrack = theITTrack
    }
    
}

class PredicateOutlineNode: NSObject {
    
    typealias Element = PredicateOutlineNode
    
    @objc dynamic var children: [Element] = [] {
        didSet {
            propagatePredicatesAndRefilterChildren()
        }
    }
    
    @objc private(set) dynamic var filteredChildren: [Element] = [] {
        didSet {
            count = filteredChildren.count
            isLeaf = filteredChildren.isEmpty
        }
    }
    
    @objc private(set) dynamic var count: Int = 0
    @objc private(set) dynamic var isLeaf: Bool = true
    
    var predicate: NSPredicate? {
        didSet {
            propagatePredicatesAndRefilterChildren()
        }
    }
    
    private func propagatePredicatesAndRefilterChildren() {
        // Propagate the predicate down the child nodes in case either
        // the predicate or the children array changed.
        children.forEach { $0.predicate = predicate }
        
        // Determine the matching leaf nodes.
        let newChildren: [Element]
        
        if let predicate = predicate {
            newChildren = children.compactMap { child -> Element? in
                if child.isLeaf, !predicate.evaluate(with: child) {
                    return nil
                }
                return child
            }
        } else {
            newChildren = children
        }
        
        // Only actually update the children if the count varies.
        if newChildren.count != filteredChildren.count {
            filteredChildren = newChildren
        }
    }
}

class iTunesModel {
    
    ////////////////// PLAYLISTS //////////////////
    
    static func getPlaylistsGroups(thePlaylists: [Playlist]) -> [PlaylistGroup] {
        var playlistsGroups: [PlaylistGroup] = [PlaylistGroup]()
        let libraryGroup : PlaylistGroup = PlaylistGroup(name: "Library")
        let allPlaylistsGroup: PlaylistGroup = PlaylistGroup(name: "All Playlists", isAllPlaylists: true)
        playlistsGroups.append(libraryGroup)
        playlistsGroups.append(allPlaylistsGroup)
        for thePlaylist in thePlaylists {
            if thePlaylist.theITPlaylist.distinguishedKind == .kindNone {
                allPlaylistsGroup.children.append(thePlaylist)
            } else {
                libraryGroup.children.append(thePlaylist)
            }
        }
        return playlistsGroups
    }
    
    static func getPlaylistsTree(theLevelITPlaylists: [ITLibPlaylist], theITPlaylists: [ITLibPlaylist]) -> [Playlist] {
        var thePlaylistsTree = [Playlist]()
        for theITPlaylist in theLevelITPlaylists {
            let thePlaylist = Playlist(thePlaylist: theITPlaylist) // a NSObject with the isLeaf bool and children array to show the tree in a NSOutlineView
            if theITPlaylist.kind == .folder {
                let theChildrenPlaylists = theITPlaylists.filter({ $0.parentID == theITPlaylist.persistentID })
                thePlaylist.children = getPlaylistsTree(theLevelITPlaylists: theChildrenPlaylists, theITPlaylists: theITPlaylists)
            }
            thePlaylistsTree.append(thePlaylist)
        }
        return thePlaylistsTree
    }
    
    static func getFlattenPlaylistsTree(theList: [Playlist], isDistinguishedKind: Bool = true, theSeparator: String = "   ", theLevel: Int = 0) -> [Playlist] {
        var theFinalList = [Playlist]()
        for thePlaylist in theList {
            if let thePlaylist = thePlaylist as? Playlist {
                let thePlaylistName = thePlaylist.name
                var theIdent = ""
                var i = 0
                while i < theLevel {
                    theIdent = theIdent + theSeparator
                    i += 1
                }
                theIdent += " "
                thePlaylist.name = theIdent + thePlaylistName!
                theFinalList.append(thePlaylist)
                if thePlaylist.isFolder {
                    let children = thePlaylist.children
                    let result = getFlattenPlaylistsTree(theList: children, theSeparator: theSeparator, theLevel: theLevel + 1)
                    for i in result {
                        theFinalList.append(i)
                    }
                }
            }
        }
        return theFinalList
    }
    
    ////////////////// ARTISTS //////////////////
    
    static func getAllArtistNames(theITTracks: [ITLibMediaItem]) -> [String] {
        var theArtistsList: [String] = [String]()
        for theITTrack in theITTracks {
            var theArtistName: String = ""
            if let theITArtistName = theITTrack.artist?.name {
                theArtistName = theITArtistName
            }
            let theIndex = theArtistsList.index(of: theArtistName)
            print("V&G_Project___getAllArtistNames : ", theIndex)
            if theIndex == nil {
                theArtistsList.append(theArtistName)
            }
            
        }
        return theArtistsList
    }
    
    static func getArtistsTree(theITTracks: [ITLibMediaItem], parseTracks: Bool = true) -> [Artist] {
        let theTracksByArtist = Dictionary(grouping: theITTracks, by: { $0.artist?.name?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
        
        var theArtistsTree = [Artist]()
        for(artistKey, tracksByArtist) in theTracksByArtist {
            let theAlbumsTracks = tracksByArtist.map{ $0 }
            let theITArtist = theAlbumsTracks.first?.artist
            let theArtist = Artist(theITArtist: theITArtist!)
            
            /*print("theArtist >>>", theArtist.name)
            print("/////////")*/
            
            let theArtistAlbums = Dictionary(grouping: theAlbumsTracks, by: { $0.album.title?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
            //print(theArtistAlbums.count, "album(s)")
            for (albumID, tracksAlbum) in theArtistAlbums {
                let theTracksAlbum = tracksAlbum.map { $0 }.sorted(by: { $0.trackNumber < $1.trackNumber })
                let theITAlbum = theTracksAlbum.first?.album
                let theAlbum = Album(theITAlbum: theITAlbum!)
                theAlbum.ITTracks = theTracksAlbum
                //print(theAlbum.name)
                
                //print(theTracksAlbum.first?.album.title, "(" + String(theTracksAlbum.count), "track(s))")
                //print("++++")
                
                if parseTracks {
                    for track in theTracksAlbum {
                        //print(track.title)
                        let theTrack = Track(theITTrack: track)
                        theAlbum.tracks.append(theTrack)
                    }
                }
                //print("***************")
                
                theArtist.albums.append(theAlbum)
            }
            
            theArtistsTree.append(theArtist)
            //print("---------------------------------------------------------------------------------------------------")
        }
        return theArtistsTree
    }
    
    public static func getiTunesTrackTitle(theiTunesTrack: ITLibMediaItem) -> String {
        return theiTunesTrack.title
    }
    
    public static func getAlbumTitle(theITTrack: ITLibMediaItem) -> String {
        var theAlbumTitle: String = ""
        if let theITAlbumName = theITTrack.album.title {
            theAlbumTitle = theITAlbumName
        }
        return theAlbumTitle
    }
    
    public static func getArtistName(theITTrack: ITLibMediaItem) -> String {
        var theArtistName: String = ""
        if let theITArtistName = theITTrack.artist?.name {
            //theArtistName = theITArtistName.replacingHTMLEntities!
            theArtistName = theITArtistName
        }
        return theArtistName
    }
    
    public static func sortITTrack(ITTrack1: ITLibMediaItem, ITTrack2: ITLibMediaItem, kind: ITSortKind) -> Bool {
        var param1: String = ""
        var param2: String = ""
        switch kind {
        case .artist:
            if let param11 = ITTrack1.artist?.name {
                param1 = param11
            }
            if let param22 = ITTrack2.artist?.name {
                param2 = param22
            }
        case .album:
            if let param11 = ITTrack1.album.title {
                param1 = param11
            }
            if let param22 = ITTrack2.album.title {
                param2 = param22
            }
        case .artistAndThenAlbum:
            var param3: String = ""
            var param4: String = ""
            
            if let param11 = ITTrack1.artist?.name {
                param1 = param11
            }
            if let param22 = ITTrack2.artist?.name {
                param2 = param22
            }
            
            if let param33 = ITTrack1.album.title {
                param3 = param33
            }
            if let param44 = ITTrack2.album.title {
                param4 = param44
            }
            return (param1, param3) < (param2, param4)
        }
        if param1 != nil && param2 != nil {
            return param1.localizedCaseInsensitiveCompare((param2)) == ComparisonResult.orderedAscending
        } else {
            return false
        }
    }
    
    private static func _getAlbumsArtist(theITTracks: [ITLibMediaItem], theITArtist: ITLibArtist) -> [Album] {
        var theAlbums: [Album] = [Album]()
        print("V&G_Project____getAlbumsArtist theITTracks.count : ", theITTracks.count)
        var i: Int = 0
        while i < theITTracks.count - 1 {
            let theITTrack = theITTracks[i]
            let theAlbum: Album = Album(theITAlbum: theITTrack.album)
            if let theAlbumTitle = theITTrack.album.title {
                let theSearch = theITTracks.filter({$0.album.title?.lowercased() == theAlbumTitle.lowercased()})
                
                i += theSearch.count
            }else{
                i += 1
            }
            theAlbums.append(theAlbum)
        }
        
        
        // dump(theSearch)
        
        
        return theAlbums
    }
    
    static func getTracksAlbum(theTracks: [ITLibMediaItem], theAlbum: ITLibAlbum) -> [Track] {
        let theTracks: [Track] = [Track]()
        
        return theTracks
    }
    
    static func getMusicPlaylists(lib: ITLibrary) -> [ITLibPlaylist] {
        let playlists = lib.allPlaylists.filter({$0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindMusic || $0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindNone})
        return playlists
    }
    
    static func getAllPlaylists(lib: ITLibrary) -> [ITLibPlaylist] {
        let playlists = lib.allPlaylists
        return playlists
    }
    
    static func getFormattedSourceList() {
        
    }
    
    static func getStatutInfos(theTracks: [ITLibMediaItem]) -> StatutInfos {
        var statutInfos: StatutInfos = StatutInfos()
        statutInfos.count = theTracks.count
        for theTrack in theTracks {
            statutInfos.duration += theTrack.totalTime
            statutInfos.size += theTrack.fileSize
        }
        return statutInfos
    }
    
    static func getFormattedTrackName(theITTrack: ITLibMediaItem, theFormattedTrackNameStyle: FormattedTrackNameStyle = .trackNameArtistNameAlbumName, theSeparator: String = " - ") -> String {
        let theTrackName: String = theITTrack.title
        let theArtistName: String = getArtistName(theITTrack: theITTrack)
        let theAlbumTitle: String = getAlbumTitle(theITTrack: theITTrack)
        var theFormattedTrackName: String = ""
        switch theFormattedTrackNameStyle {
        case .trackNameArtistNameAlbumName:
            theFormattedTrackName = theTrackName + theSeparator + theArtistName + theSeparator + theAlbumTitle
        case .artistNameTrackName:
            theFormattedTrackName = theArtistName + theSeparator + theTrackName
        }
        return theFormattedTrackName
    }
    
    static func getDestinationPattern(theITTrack: ITLibMediaItem, fileNameType: iTunesExportFileNameType) -> String {
        var theDestinationPattern: String = ""
        let theFileName: String = (theITTrack.location?.getName())!
        let theAlbumName = getAlbumTitle(theITTrack: theITTrack)
        //let theAlbumName = "album_name"
        let theArtistName = getArtistName(theITTrack: theITTrack)
        //let theArtistName = "artist_name"
        switch fileNameType {
        case iTunesExportFileNameType.fileName:
            theDestinationPattern = theFileName
        case iTunesExportFileNameType.albumSlashFileName:
            theDestinationPattern = theAlbumName + "/" + theFileName
        case iTunesExportFileNameType.artistSepAlbumSlashFileName:
            theDestinationPattern = theArtistName + " - " + theAlbumName + "/" + theFileName
        case iTunesExportFileNameType.artistSlashAlbumSlashFileName:
            theDestinationPattern = theArtistName + "/" + theAlbumName + "/" + theFileName
        case iTunesExportFileNameType.artistSlashFileName:
            theDestinationPattern = theArtistName + "/" + theFileName
        }
        return theDestinationPattern
    }
    
    static func getTracksFromITTracks(theITTracks: [ITLibMediaItem], theITSortKind: ITSortKind = ITSortKind.artistAndThenAlbum) -> [Track] {
        var theTracks: [Track] = [Track]()
        let theITTracksSorted = theITTracks.sorted(by: {iTunesModel.sortITTrack(ITTrack1: $0, ITTrack2: $1, kind: theITSortKind)})
        let theCount = theITTracksSorted.count - 1
        for i in 0...theCount {
            let theITTrack = theITTracksSorted[i]
            let theTrack: Track = Track(theITTrack: theITTrack)
            theTracks.append(theTrack)
            print("V&G_FW___getTracksFromITTracks : ", i, theCount)
        }
        return theTracks
    }
    
    /*
     
     to getFormatedTrackName(theTrack, theStyle)
     tell application "iTunes"
     try
     set trackName to name of theTrack
     set artistName to artist of theTrack
     set albumName to album of theTrack
     if theStyle is _formatedTrackNameTrackNameArtistNameAlbumName_ then
     if (albumName = "") then
     set str to ("\"" & trackName & "\"" & " by " & artistName & " in unknown album")
     else
     set str to ("\"" & trackName & "\"" & " by " & artistName & " in " & albumName)
     end if
     end if
     on error
     display dialog "error with the method getFormatedTrackName()"
     end try
     end tell
     return str
     end getFormatedTrackName
     */
    
    
}

enum FormattedTrackNameStyle: Int {
    case trackNameArtistNameAlbumName = 0
    case artistNameTrackName = 1
}

enum ITSortKind: Int {
    case artist = 0
    case album = 1
    case artistAndThenAlbum = 2
}

struct StatutInfos {
    var count: Int = 0
    var duration: Int = 0
    var size: UInt64 = 0
}

enum iTunesExportFileNameType: String {
    case fileName = "file_name"
    case artistSepAlbumSlashFileName = "artist-album/file_name"
    case artistSlashAlbumSlashFileName = "<artist>/<album>/<file_name>"
    case albumSlashFileName = "<album>/<file name>"
    case artistSlashFileName = "<artist>/<file name>"
}


struct ArtistTreeObject {
    
    let track: Track?
    let current: Int?
    let total: Int?
    
}
