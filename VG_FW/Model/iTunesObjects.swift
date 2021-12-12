//
//  iTunesObjects.swift
//  Swift-AppleScriptObjC
//
//  Created by Developer on 24/01/2019.
//

import Foundation
import iTunesLibrary

class NodeGroup: Node {
    
    private var _id: Int
    
    @objc override func isLeaf() -> Bool {
        return false
    }
    
    init(name: String, id: Int) {
        self._id = id
        super.init()        
        super.name = name
    }
    
    var id: Int {
        get {
            return _id
        }
    }
    
}

class Node: NSObject {
    @objc dynamic var name: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var children: [Node]?
    var isSearched: Bool = false
    
    @objc func isLeaf() -> Bool {
        return false
    }
    
}

class ITNode: Node {
    
    private var _ITObject: NSObject
    
    init(ITObject: NSObject) {
        _ITObject = ITObject
    }
    
    var ITObject: NSObject {
        get {
            return _ITObject
        }
    }
    
}

class Playlist: ITNode {
    
    @objc dynamic var isFolder: Bool = false
    @objc dynamic var isSmart: Bool = false
    var kind: ITLibPlaylistKind?
    
    private var _ITPlaylist: ITLibPlaylist
    
    var ITPlaylist: ITLibPlaylist {
        get {
            return _ITPlaylist
        }
    }
    
    var duration: Int {
        get {
            var duration: Int = 0
            for theITTrack in ITPlaylist.items {
                duration += theITTrack.totalTime / 1000
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var theSize: UInt64 = 0
            for theITTrack in ITPlaylist.items {
                theSize += theITTrack.fileSize
            }
            return theSize
        }
    }
    
    var tracks: [Track] {
        get {
            return iTunesModel.getTracksFromITTracks(theITTracks: ITPlaylist.items)
        }
    }
    
    @objc override func isLeaf() -> Bool {
        var hasChildren: Bool = false
        if let theChildren = children {
            if theChildren.count > 0 {
                hasChildren = true
            }
        }
        var theBool = true
        if isFolder && !isSearched && hasChildren {
            theBool = false
        }
        return theBool
    }
    
    override init(ITObject: NSObject) {
        _ITPlaylist = ITObject as! ITLibPlaylist
        super.init(ITObject: ITObject)
        
        super.name = _ITPlaylist.name
        self.isFolder = _ITPlaylist.kind == .folder
        self.isSmart = kind == .smart
        if ITPlaylist.kind == .folder {
            children = [Playlist]()
        }
    }
}

class Artist: ITNode {
    
    private var _ITArtist: ITLibArtist
    
    @objc override func isLeaf() -> Bool {
        var hasChildren: Bool = false
        if let theChildren = children {
            if theChildren.count > 0 {
                hasChildren = true
            }
        }
        var theBool = true
        if !isSearched && hasChildren {
            theBool = false
        }
        return theBool
    }
    
    override init(ITObject: NSObject) {
        _ITArtist = ITObject as! ITLibArtist
        super.init(ITObject: ITObject)
        
        if let theArtistName = _ITArtist.name {
            super.name = theArtistName
        }
        children = [Album]()
    }
    
    func getTracks() -> [Track] {
        var theTrack = [Track]()
        let theAlbums = children as! [Album]
        for album in theAlbums {
            for track in album.tracks {
                theTrack.append(track)
            }
        }
        return theTrack
    }
    
    func getITTracks() -> [ITLibMediaItem] {
        var theITTracks = [ITLibMediaItem]()
        let theAlbums = children as! [Album]
        for album in theAlbums {
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

class Album: ITNode {
    
    //@objc dynamic var name = ""
    @objc dynamic var tracks = [Track]()
    var ITTracks = [ITLibMediaItem]()
    private var _ITAlbum: ITLibAlbum
    
    @objc override func isLeaf() -> Bool {
        return true
    }
    
    override init(ITObject: NSObject) {
        _ITAlbum = ITObject as! ITLibAlbum
        super.init(ITObject: ITObject)
        
        if let theAlbumName = _ITAlbum.title {
            super.name = theAlbumName
        }
    }
    
    var ITAlbum: ITLibAlbum {
        get {
            return _ITAlbum
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

class Track: ITNode {
    
    //@objc dynamic var artist: String = ""
    //@objc dynamic var album: String = ""
    //@objc dynamic var duration: Int = 0
    //@objc dynamic var size: UInt64 = 0
    //@objc dynamic var location: URL?
    private var _theITTrack: ITLibMediaItem
    
    override init(ITObject: NSObject) {
        _theITTrack = ITObject as! ITLibMediaItem
        super.init(ITObject: ITObject)
        
        /*if let theTrackName = _theITTrack.title {
            super.name = theTrackName
        }*/
        super.name = _theITTrack.title
        //children = [Track]()
    }
    
    var ITTrack: ITLibMediaItem {
        get {
            return _theITTrack
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
    
    enum PlaylistsGroupID: Int {
        case library = 0
        case allPlaylists = 1
    }
    
    static func getPlaylistsGroups(playlists: [Playlist]) -> [NodeGroup] {
        var thePlaylistsGroup = [NodeGroup]()
        let theLibraryGroup : NodeGroup = NodeGroup(name: "Bibliothèque", id: PlaylistsGroupID.library.rawValue)
        let theAllPlaylistsGroup: NodeGroup = NodeGroup(name: "Toutes les playlists perso", id: PlaylistsGroupID.allPlaylists.rawValue)
        thePlaylistsGroup.append(theLibraryGroup)
        thePlaylistsGroup.append(theAllPlaylistsGroup)
        theAllPlaylistsGroup.children = playlists.filter({ $0.ITPlaylist.distinguishedKind == .kindNone })
        theLibraryGroup.children = playlists.filter({ $0.ITPlaylist.distinguishedKind == .kindMusic })
        return thePlaylistsGroup
    }
    
    static func getPlaylistsTree(theLevelITPlaylists: [ITLibPlaylist], theITPlaylists: [ITLibPlaylist]) -> [Playlist] {
        var thePlaylistsTree = [Playlist]()
        for theITPlaylist in theLevelITPlaylists {
            let thePlaylist = Playlist(ITObject: theITPlaylist) // a NSObject with the isLeaf bool and children array to show the tree in a NSOutlineView
            if theITPlaylist.kind == .folder {
                let theChildrenPlaylists = theITPlaylists.filter({ $0.parentID == theITPlaylist.persistentID })
                thePlaylist.children = getPlaylistsTree(theLevelITPlaylists: theChildrenPlaylists, theITPlaylists: theITPlaylists)
            }
            thePlaylistsTree.append(thePlaylist)
        }
        return thePlaylistsTree
    }
    
    /*static func getFlattenPlaylistsTree(playlists: [Playlist], isIndent: Bool = false, separator: String = "   ", level: Int = 0) -> [Playlist] {
        var theFlattenPlaylists = [Playlist]()
        for thePlaylist in playlists {
            if isIndent && level > 0 { // to avoid the while useless in the first level
                let thePlaylistName = thePlaylist.name
                var theIdent = ""
                var i = 0
                while i < level {
                    theIdent = theIdent + separator
                    i += 1
                }
                thePlaylist.name = theIdent + thePlaylistName
            }
            theFlattenPlaylists.append(thePlaylist)
            if thePlaylist.theITPlaylist.kind == .folder {
                theFlattenPlaylists.append(contentsOf: getFlattenPlaylistsTree(playlists: (thePlaylist.children! as? [Playlist])!, isIndent: isIndent, separator: separator, level: level + 1))
            }
        }
        return theFlattenPlaylists
    }*/
    
    static func getFlattenNodesTree(nodes: [Node], isIndent: Bool = false, separator: String = "   ", level: Int = 0) -> [Node] {
        var theFlattenNodes = [Node]()
        for theNode in nodes {
            if isIndent && level > 0 { // to avoid the while useless in the first level
                let theNodeName = theNode.name
                var theIdent = ""
                var i = 0
                while i < level {
                    theIdent = theIdent + separator
                    i += 1
                }
                theNode.name = theIdent + theNodeName
            }
            theFlattenNodes.append(theNode)
            if let theChildren = theNode.children {
                if theChildren.count > 0 {
                    theFlattenNodes.append(contentsOf: getFlattenNodesTree(nodes: theChildren, isIndent: isIndent, separator: separator, level: level + 1))
                }
            }
        }
        return theFlattenNodes
    }
    
    ////////////////// ARTISTS //////////////////
    
    enum ArtistsGroupID: Int {
        case allArtists = 0
        case compilation = 1
    }
    
    static func getArtistsGroups(ITNodesList: [[ITNode]]) -> [NodeGroup] {
        var theArtistsGroup = [NodeGroup]()
        let theAllArtistsGroup : NodeGroup = NodeGroup(name: "Tous les artistes", id: ArtistsGroupID.allArtists.rawValue)
        let theCompilationsGroup: NodeGroup = NodeGroup(name: "Compilation", id: ArtistsGroupID.compilation.rawValue)
        
        if let theArtistsTree = ITNodesList.first {
            theAllArtistsGroup.children = theArtistsTree.map({$0})
        }
        if ITNodesList[1] != nil {
            theCompilationsGroup.children = ITNodesList[1].map({$0})
        }
        theArtistsGroup.append(theAllArtistsGroup)
        theArtistsGroup.append(theCompilationsGroup)
        /*theAllPlaylistsGroup.children = ITNodes.filter({ $0.theITPlaylist.distinguishedKind == .kindNone })
        theAllArtistsGroup.children = ITNodes.filter({ $0.theITPlaylist.distinguishedKind == .kindMusic })*/
        return theArtistsGroup
    }
    
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
    
    static func getArtistsTree(ITTracks: [ITLibMediaItem], parseTracks: Bool = true) -> [Artist] {
        let theTracksByArtist = Dictionary(grouping: ITTracks, by: { $0.artist?.name?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
        let theCompilations = Dictionary(grouping: ITTracks, by: { $0.album.title })
        
        var theArtistsTree = [Artist]()
        for(artistKey, tracksByArtist) in theTracksByArtist {
            let theITAlbumsTracks = tracksByArtist.map{ $0 }
            let theITArtist = theITAlbumsTracks.first?.artist
            let theArtist = Artist(ITObject: theITArtist!)
            
            theArtist.children?.append(contentsOf: getAlbumsTree(ITTracks: theITAlbumsTracks, parseTracks: parseTracks))
            
            /*let theGroupedITArtistAlbums = Dictionary(grouping: theITAlbumsTracks, by: { $0.album.title?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
            for (albumID, tracksAlbum) in theGroupedITArtistAlbums {
                let theITTracksAlbum = tracksAlbum.map { $0 }.sorted(by: { $0.trackNumber < $1.trackNumber })
                let theITAlbum = theITTracksAlbum.first?.album
                let theAlbum = Album(ITObject: theITAlbum!)
                theAlbum.ITTracks = theITTracksAlbum
                
                if parseTracks {
                    for track in theITTracksAlbum {
                        //print(track.title)
                        let theTrack = Track(ITObject: track)
                        theAlbum.tracks.append(theTrack)
                    }
                }
                
                theArtist.children?.append(theAlbum)
            }*/
            
            theArtistsTree.append(theArtist)
        }
        return theArtistsTree
    }
    
    static func getAlbumsTree(ITTracks: [ITLibMediaItem], parseTracks: Bool = true) -> [Album] {
        var theAlbums = [Album]()
        
        let theITAlbums = Dictionary(grouping: ITTracks, by: { $0.album.title?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
        
        for (albumID, tracksAlbum) in theITAlbums {
            let theITTracksAlbum = tracksAlbum.map { $0 }.sorted(by: { $0.trackNumber < $1.trackNumber })
            let theITAlbum = theITTracksAlbum.first?.album
            let theAlbum = Album(ITObject: theITAlbum!)
            theAlbum.ITTracks = theITTracksAlbum
            //print(theAlbum.name)
            
            //print(theTracksAlbum.first?.album.title, "(" + String(theTracksAlbum.count), "track(s))")
            //print("++++")
            
            if parseTracks {
                for ITTrack in theITTracksAlbum {
                    //print(track.title)
                    let theTrack = Track(ITObject: ITTrack)
                    theAlbum.tracks.append(theTrack)
                }
            }
            //print("***************")
            
            theAlbums.append(theAlbum)
        }
        
        return theAlbums
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
            let theAlbum: Album = Album(ITObject: theITTrack.album)
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
        var thePlaylists = lib.allPlaylists.filter({$0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindMusic || $0.distinguishedKind == ITLibDistinguishedPlaylistKind.kindNone})
        if thePlaylists.count > 0 {
            if let theLibraryPlaylist = thePlaylists.first {
                if theLibraryPlaylist.kind == .regular {
                    thePlaylists.remove(at: 0)
                }
            }
        }
        return thePlaylists
    }
    
    static func getAllPlaylists(lib: ITLibrary) -> [ITLibPlaylist] {
        let thePlaylists = lib.allPlaylists
        return thePlaylists
    }
    
    static func getStatutInfos(theTracks: [ITLibMediaItem]) -> StatutInfos {
        var statutInfos = StatutInfos()
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
            let theTrack: Track = Track(ITObject: theITTrack)
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
