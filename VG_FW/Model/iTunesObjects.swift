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
    @objc dynamic var children: [Playlist]?
    private(set) var theITPlaylist: ITLibPlaylist
    
    var duration: Int {
        get {
            var duration: Int = 0
            for theITTrack in theITPlaylist.items {
                let theTrack: Track = Track(theITTrack: theITTrack)
                duration += theTrack.duration
            }
            return duration
        }
    }
    
    var size: UInt64 {
        get {
            var size: UInt64 = 0
            for theITTrack in theITPlaylist.items {
                let theTrack: Track = Track(theITTrack: theITTrack)
                size += theTrack.size
            }
            return size
        }
    }
    
    var tracks: [Track] {
        get {
            return iTunesModel.getTracksFromITTracks(theITTracks: theITPlaylist.items)
        }
    }
    
    @objc func isLeaf() -> Bool {
        return !(self.isFolder)
    }
    
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
    //private(set) var theITTrack: ITLibMediaItem
    
    init(theITTrack: ITLibMediaItem) {
        self.artist = iTunesModel.getArtistName(theITTrack: theITTrack)
        self.artist = ""
        self.name = theITTrack.title
        if let theAlbumName = theITTrack.album.title {
            self.album = theAlbumName
        }
        //self.duration = theITTrack.totalTime
        //self.size = theITTrack.fileSize
        self.location = theITTrack.location
        //self.theITTrack = theITTrack
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
                        theList[theIndex!].children?.append(theItem)
                    }
                } else {
                    theFinalList.append(theItem)
                }
            } else {
                if hasParent {
                    if let thePlaylistParent = self._getPlaylistParent(thePlaylistID: theITPlaylist.parentID!, thePlaylists: theITPlaylists) {
                        let thePlaylistParentID = thePlaylistParent.persistentID
                        let theIndex = thePlaylistsList.index(of: thePlaylistParentID)
                        theList[theIndex!].children?.append(theItem)
                    }
                } else {
                    theFinalList.append(theItem)
                }
            }
            
            /*if hasParent {
             if isFolder {
             
             } else {
             
             }
             } else {
             if isFolder {
             
             } else {
             
             }
             }*/
            
            theList.append(theItem)
            
        }
        print("V&G_Project___<#name#> : ", theFinalList.count)
        return theFinalList
    }
    
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
        var theArtists: [Artist] = [Artist]()
        
        let theITTrackSorted = theITTracks.sorted(by: {self.sortITTrack(ITTrack1: $0, ITTrack2: $1, kind: ITSortKind.artistAndThenAlbum)})
        var theArtistNamesList: [String] = [String]()
        
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
        }
        
        return theArtists
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
            theArtistName = theITArtistName.replacingHTMLEntities!
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
    
    static func getStatutInfos(theTracks: [Track]) -> StatutInfos {
        var statutInfos: StatutInfos = StatutInfos()
        statutInfos.count = theTracks.count
        for theTrack in theTracks {
            statutInfos.duration += theTrack.duration
            statutInfos.size += theTrack.size
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
        default:
            print("V&G_Project___getFormattedTrackName : ", self)
        }
        return theFormattedTrackName
    }
    
    static func getDestinationPattern(theTrack: Track, fileNameType: iTunesExportFileNameType) -> String {
        var theDestinationPattern: String = ""
        let theFileName: String = (theTrack.location?.getName())!
        let theAlbumName = theTrack.album
        //let theAlbumName = "album_name"
        let theArtistName = theTrack.artist
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
