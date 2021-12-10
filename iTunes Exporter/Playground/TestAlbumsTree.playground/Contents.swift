import Cocoa
import iTunesLibrary

do {
    let lib = try ITLibrary(apiVersion: "1.1")
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong})
    let theITTracksNoCompilation = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && !$0.album.isCompilation })
    let theITTracksCompilations = lib.allMediaItems.filter({ $0.mediaKind == .kindSong && $0.album.isCompilation })
    print(theITTracksCompilations.count)
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot")})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "slipknot")})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name?.lowercased() == "disturbed" || $0.artist?.name?.lowercased() == "iron maiden" || $0.artist?.name?.lowercased() == "metallica" || $0.artist?.name?.lowercased() == "queen" || $0.artist?.name?.lowercased() == "slipknot" || $0.artist?.name == nil)})
    
    //let theITTracks = lib.allMediaItems.filter({$0.mediaKind == .kindSong && ($0.artist?.name == nil)})
    
    let theAlbumsTree = iTunesModel.getAlbumsTree(ITTracks: theITTracksNoCompilation)
    let theAlbumsTreeNames = theAlbumsTree.map({ $0.name })
    dump(theAlbumsTreeNames)
    
    
} catch let error {
    print("V&G_Project___buildView : ", error)
}
