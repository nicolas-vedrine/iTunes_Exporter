import Cocoa
import iTunesLibrary

do {
    let lib = try ITLibrary(apiVersion: "1.1")
    let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong})
    let theITTracksNoCompilation = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && !$0.album.isCompilation })
    let theITTracksCompilations = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && $0.album.isCompilation })
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot")})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "slipknot")})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot" || $0.artist?.name == nil)})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name == nil)})
    
    let theArtistsTree = iTunesModel.getArtistsTree(ITTracks: theITTracks, parseTracks: true)
    //dump(theArtistsTree.map({ $0.name }))
    let theCompilationsTree = iTunesModel.getAlbumsTree(ITTracks: theITTracksCompilations, parseTracks: false)
    
    let theFlattenArtistsTree = iTunesModel.getFlattenNodesTree(nodes: theArtistsTree, isIndent: true)
    let theFlattenArtistsTreeNames = theFlattenArtistsTree.map({$0.name})
    //dump(theFlattenArtistsTree)
    
    let theFlattenCompilationsTree = iTunesModel.getFlattenNodesTree(nodes: theCompilationsTree)
    let theFlattenCompilationsTreeNames = theFlattenCompilationsTree.map({$0.name})
    //dump(theFlattenCompilationsTreeNames)
    
    /*let theArtistIndex = theArtistsTree.count > 1 ? Int.random(in: 0..<theArtistsTree.count - 1) : 0
    let theRandomArtist = theArtistsTree[theArtistIndex]
    let theRandomBool: Bool = Int.random(in: 0..<1) == 0 ? false : true
    //let theRandomBool: Bool = false
    var theArtistTracks = [Track]()
    var theArtistITTracks = [ITLibMediaItem]()
    if theRandomBool {
        let theRandomAlbumInt = Int.random(in: 0..<theRandomArtist.children!.count - 1)
        let theRandomAlbum = theRandomArtist.children![theRandomAlbumInt]
        theArtistTracks = theRandomAlbum.tracks
    } else {
        theArtistITTracks = theRandomArtist.getITTracks()
    }
    //dump(theArtistITTracks)
    //print(theRandomArtist.name, theTracks.count)*/
    
} catch let error {
    print("V&G_Project___buildView : ", error)
}
