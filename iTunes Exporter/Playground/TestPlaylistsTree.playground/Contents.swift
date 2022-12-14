import Cocoa
import iTunesLibrary

do {
    let lib = try ITLibrary(apiVersion: "1.1")
    let theITPlaylists = iTunesModel.getMusicPlaylists(lib: lib)
    print("theITPlaylists.count", theITPlaylists.count)
    
    let theRootITPlaylists = theITPlaylists.filter({ $0.parentID == nil })
    
    let thePlaylistsTree: [Playlist] = iTunesModel.getPlaylistsTree(theLevelITPlaylists: theRootITPlaylists, theITPlaylists: theITPlaylists)
    
    let theFlattenPlaylists: [Playlist] = iTunesModel.getFlattenNodesTree(nodes: thePlaylistsTree, isIndent: true) as! [Playlist]
    let theFlattenPlaylistsNames = theFlattenPlaylists.map({$0.name})
    
    print("theFlattenPlaylistsNames.count", theFlattenPlaylistsNames.count)
    dump(theFlattenPlaylistsNames)
    
} catch let error {
    print("V&G_Project___buildView : ", error)
}

/*func flattenPlaylists(playlists: [Playlist], isIndent: Bool = false, separator: String = "   ", level: Int = 0) -> [Playlist] {
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
            theFlattenPlaylists.append(contentsOf: flattenPlaylists(playlists: thePlaylist.children!, isIndent: isIndent, separator: separator, level: level + 1))
        }
    }
    return theFlattenPlaylists
}*/

/*func flattenArray(_ array: [Any]) -> [Any] {
    var result = [Any]()
    for element in array {
        //print(type(of: element))
        if let element = element as? [Any] {
            //print("ok")
            result.append(contentsOf: flattenArray(element))
        } else {
            //print("okok")
            result.append(element)
        }
    }
    return result
}*/

/*func getPlaylistsTree(theLevelITPlaylists: [ITLibPlaylist], theITPlaylists: [ITLibPlaylist]) -> [Playlist] {
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
        
        thePlaylistsTree.append(thePlaylist)
    }
    return thePlaylistsTree
}*/

/*func getITPlaylistChildren(theFolderITPlaylist: ITLibPlaylist, theITPlaylists: [ITLibPlaylist]) -> [ITLibPlaylist] {
    //var theChildrenPlaylists = [ITLibPlaylist]()
    let theChildrenITPlaylists = theITPlaylists.filter({ $0.parentID == theFolderITPlaylist.persistentID })
    /*for theChildITPlaylist in theChildrenITPlaylists {
        theChildrenPlaylists.append(theChildITPlaylist)
    }*/
    return theChildrenITPlaylists
}*/
