import Cocoa
import iTunesLibrary

do {
    let lib = try ITLibrary(apiVersion: "1.1")
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong})
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot")})
    
    let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "slipknot")})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot" || $0.artist?.name == nil)})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name == nil)})
    
    let theTracksByArtist = Dictionary(grouping: theITTracks, by: { $0.artist?.name?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
    
    var theArtistsTree = [Artist]()
    for(artistKey, tracksByArtist) in theTracksByArtist {
        let theAlbumsTracks = tracksByArtist.map{ $0 }
        let theITArtist = theAlbumsTracks.first?.artist
        let theArtist = Artist(theITArtist: theITArtist!)
        
        print("theArtist >>>", theArtist.name)
        print("/////////")
        
        let theArtistAlbums = Dictionary(grouping: theAlbumsTracks, by: { $0.album.title?.lowercased() ?? "--" } ).sorted(by: { $0.key.localizedStandardCompare($1.key) == .orderedAscending })
        print(theArtistAlbums.count, "album(s)")
        for (albumID, tracksAlbum) in theArtistAlbums {
            let theTracksAlbum = tracksAlbum.map { $0 }.sorted(by: { $0.trackNumber < $1.trackNumber })
            let theITAlbum = theTracksAlbum.first?.album
            let theAlbum = Album(theITAlbum: theITAlbum!)
            //print(theAlbum.name)
            
            print(theTracksAlbum.first?.album.title, "(" + String(theTracksAlbum.count), "track(s))")
            print("++++")
            
            for track in theTracksAlbum {
                print(track.title)
                let theTrack = Track(theITTrack: track)
                theAlbum.tracks.append(theTrack)
            }
            print("***************")
            
            theArtist.albums.append(theAlbum)
        }
        
        theArtistsTree.append(theArtist)
        print("---------------------------------------------------------------------------------------------------")
    }
    
    print(theArtistsTree.count)
    
    let theArtistIndex = theArtistsTree.count > 1 ? Int.random(in: 0..<theArtistsTree.count - 1) : 0
    let theRandomArtist = theArtistsTree[theArtistIndex]
    let theRandomBool: Bool = Int.random(in: 0..<1) == 0 ? false : true
    //let theRandomBool: Bool = false
    var theArtistTracks = [Track]()
    var theArtistITTracks = [ITLibMediaItem]()
    if theRandomBool {
        let theRandomAlbumInt = Int.random(in: 0..<theRandomArtist.albums.count - 1)
        let theRandomAlbum = theRandomArtist.albums[theRandomAlbumInt]
        theArtistTracks = theRandomAlbum.tracks
        //theArtistITTracks = theRandomAlbum.getITTracks()
    } else {
        theArtistITTracks = theRandomArtist.getITTracks()
    }
    dump(theArtistITTracks)
    //print(theRandomArtist.name, theTracks.count)
    
} catch let error {
    print("V&G_Project___buildView : ", error)
}
