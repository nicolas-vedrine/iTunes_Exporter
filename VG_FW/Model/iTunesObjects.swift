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

class Playlist: NSObject {
    
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
                //let theTrack: Track = Track(theITTrack: theITTrack)
                duration += theITTrack.totalTime / 1000
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var size: UInt64 = 0
            for theITTrack in theITPlaylist.items {
                //let theTrack: Track = Track(theITTrack: theITTrack)
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

class Artist: NSObject {
    
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
    
}

class Album: NSObject {
    
    @objc dynamic var name: String = ""
    @objc dynamic var tracks: [Track] = [Track]()
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
        //self.duration = theITTrack.totalTime
        //self.size = theITTrack.fileSize
        self.location = theITTrack.location
        self.theITTrack = theITTrack
    }
    
}

class VGITLib: ITLibrary {
    
    override var allMediaItems: [ITLibMediaItem] {
        get {
            return super.allMediaItems
        }
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
    
    static func getPlaylistsTree(theITPlaylists: [ITLibPlaylist], theLenght: Int) -> [Playlist] {
        var theList: [Playlist] = [Playlist]()
        var thePlaylistsList: [NSNumber] = [NSNumber]()
        var theFinalList: [Playlist] = [Playlist]()
        
        for i in 0...theLenght - 1 {
            let theITPlaylist = theITPlaylists[i]
            let thePlaylistID = theITPlaylist.persistentID
            let isFolder: Bool = theITPlaylist.kind == .folder
            let hasParent: Bool = self._hasParentPlaylist(thePlaylist: theITPlaylist)
            
            thePlaylistsList.append(thePlaylistID)
            
            let theItem: Playlist = Playlist(thePlaylist: theITPlaylist)
            
            if isFolder {
                if hasParent {
                    if let thePlaylistParent = self._getPlaylistParent(thePlaylistID: theITPlaylist.parentID!, thePlaylists: theITPlaylists) {
                        let thePlaylistParentID = thePlaylistParent.persistentID
                        let theIndex = thePlaylistsList.index(of: thePlaylistParentID)
                        theList[theIndex!].children.append(theItem)
                    }
                } else {
                    theFinalList.append(theItem)
                }
            } else {
                if hasParent {
                    if let thePlaylistParent = self._getPlaylistParent(thePlaylistID: theITPlaylist.parentID!, thePlaylists: theITPlaylists) {
                        let thePlaylistParentID = thePlaylistParent.persistentID
                        let theIndex = thePlaylistsList.index(of: thePlaylistParentID)
                        theList[theIndex!].children.append(theItem)
                    }
                } else {
                    theFinalList.append(theItem)
                }
            }
            
            theList.append(theItem)
            
        }
        return theFinalList
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
    
    /*private static func _getFlattenPlaylist(thePlaylist: Playlist) -> [Playlist] {
     var theList = [Playlist]()
     if let theChildren = thePlaylist.children {
     for theChild in theChildren {
     theList.append(theChild)
     let theChildrenList = _getFlattenPlaylist(thePlaylist: theChild)
     if theChildrenList.count > 0 {
     for item in theChildrenList {
     
     }
     }
     }
     }
     return theList
     }*/
    
    private static func _getPlaylistParent(thePlaylistID: NSNumber, thePlaylists: [ITLibPlaylist]) -> ITLibPlaylist! {
        if let thePlaylistParentID = thePlaylists.first(where: {$0.persistentID == thePlaylistID}) {
            return thePlaylistParentID
        } else {
            return nil
        }
    }
    
    private static func _hasParentPlaylist(thePlaylist: ITLibPlaylist) -> Bool {
        let theParentPlaylistID = thePlaylist.parentID
        return theParentPlaylistID == nil ? false : true
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
    
    static func getArtistsTree(theITTracks: [ITLibMediaItem], theLenght: Int, isRecursive: Bool = false) -> [Artist] {
        var theArtists = [Artist]()
        
        //let theITArtists = 
        
        /*let theITTrackSorted = theITTracks.sorted(by: {self.sortITTrack(ITTrack1: $0, ITTrack2: $1, kind: ITSortKind.artistAndThenAlbum)})
        var theArtistNamesList = [String]()
        
        for i in 0...theLenght - 1 {
            let theITTrack = theITTrackSorted[i]
            var theArtist: Artist
            var theAlbum: Album
            let theTrack = Track(theITTrack: theITTrack)
            var theArtistName: String = ""
            if let theITArtistName: String = theITTrack.artist?.name {
                theArtistName = theITArtistName
            }
            let theArtistNameLowercased = theArtistName.lowercased()
            // si l'artiste est deja dans la liste
            if let theIndex = theArtistNamesList.index(of: theArtistNameLowercased) {
                if isRecursive {
                    theArtist = theArtists[theIndex]
                    var theAlbumTitle: String = ""
                    if let theITAlbumName = theITTrack.album.title {
                        theAlbumTitle = theITAlbumName
                    }
                    if let theArtistAlbumFound = theArtist.getAlbum(by: theAlbumTitle) {
                        theAlbum = theArtistAlbumFound
                    } else {
                        //print("V&G_Project___getArtistsTree : ", "new album ----------------------------------- " + theAlbumTitle)
                        theAlbum = Album(theITAlbum: theITTrack.album)
                        theArtist.albums.append(theAlbum)
                        //print("V&G_Project___getArtistsTree : ", "album added : ", theAlbumTitle)
                    }
                    theAlbum.tracks.append(theTrack)
                    //print("V&G_Project___getArtistsTree : ", "track added : ", theITTrack.title)
                }
            } else {
                //print("V&G_Project___getArtistsTree : ", "------------------------------------------------------------------------------------")
                theArtistNamesList.append(theArtistNameLowercased)
                //print("V&G_Project___getArtistsTree : ", "artist added : ", theArtistNameLowercased)
                theArtist = Artist(theITArtist: theITTrack.artist!)
                theAlbum = Album(theITAlbum: theITTrack.album)
                theArtist.albums.append(theAlbum)
                //print("V&G_Project___getArtistsTree : ", "album added : ", theITTrack.album.title)
                theAlbum.tracks.append(theTrack)
                //print("V&G_Project___getArtistsTree : ", "track added : ", theITTrack.title)
                theArtists.append(theArtist)
            }
            
            let theCurrent: Int = i + 1
            //NotificationCenter.default.post(name: .ARTIST_TREE_LOADING, object: ArtistTreeObject(track: theTrack, current: theCurrent, total: theLenght))
        }*/
        
        return theArtists
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
