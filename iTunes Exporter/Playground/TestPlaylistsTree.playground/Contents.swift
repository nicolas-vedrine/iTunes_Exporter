import Cocoa
import iTunesLibrary

do {
    let lib = try ITLibrary(apiVersion: "1.1")
    //let theITPlaylists = lib.allPlaylists
    let theITPlaylists = iTunesModel.getMusicPlaylists(lib: lib)
    
    /*let theFolderITPlaylists = theITPlaylists.filter({ $0.kind == .folder })
    print(theFolderITPlaylists.count)*/
    let theRootITPlaylists = theITPlaylists.filter({ $0.parentID == nil })
    
    let thePlaylistsTree = getPlaylistsTree(theLevelITPlaylists: theRootITPlaylists, theITPlaylists: theITPlaylists)
    //dump(thePlaylistsTree)
    for thePlaylist in thePlaylistsTree {
        dump(thePlaylist)
        print("-------------------------")
    }
    
} catch let error {
    print("V&G_Project___buildView : ", error)
}

func getPlaylistsTree(theLevelITPlaylists: [ITLibPlaylist], theITPlaylists: [ITLibPlaylist]) -> [Playlist] {
    var thePlaylistsTree = [Playlist]()
    var theNewITPlaylists = theITPlaylists
    for theITPlaylist in theLevelITPlaylists {
        
        let theIndex = theNewITPlaylists.firstIndex(where: {$0.persistentID == theITPlaylist.persistentID})
        theNewITPlaylists.remove(at: theIndex!)
        
        let thePlaylist = Playlist(thePlaylist: theITPlaylist)
        if theITPlaylist.kind == .folder {
            //print(theNewITPlaylists.count)
            let theChildrenPlaylists = getITPlaylistChildren(theFolderITPlaylist: theITPlaylist, theITPlaylists: theNewITPlaylists)
            thePlaylist.children = getPlaylistsTree(theLevelITPlaylists: theChildrenPlaylists, theITPlaylists: theNewITPlaylists)
        }
        
        print(theNewITPlaylists.count)
        
        thePlaylistsTree.append(thePlaylist)
    }
    return thePlaylistsTree
}

func getITPlaylistChildren(theFolderITPlaylist: ITLibPlaylist, theITPlaylists: [ITLibPlaylist]) -> [ITLibPlaylist] {
    var theChildrenPlaylists = [ITLibPlaylist]()
    //print(theITPlaylists.count)
    let theChildrenITPlaylists = theITPlaylists.filter({ $0.parentID == theFolderITPlaylist.persistentID })
    for theChildITPlaylist in theChildrenITPlaylists {
        theChildrenPlaylists.append(theChildITPlaylist)
    }
    return theChildrenPlaylists
}
