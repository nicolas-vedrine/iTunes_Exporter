//
//  PlaylistTableCellView.swift
//  Swift-AppleScriptObjC
//
//  Created by Developer on 23/01/2019.
//

import Cocoa

class TreeTableCellView: NSTableCellView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    func buildCell(node: NSObject) {
        if node is Playlist {
            let thePlaylist: Playlist = node as! Playlist
            _buildPlaylist(playlist: thePlaylist)
        } else if node is Artist {
            let theArtist: Artist = node as! Artist
            imageView?.image = NSImage(named: "artist-icon")
        } else if node is Album {
            let theAlbum: Album = node as! Album
            _buildAlbum(album: theAlbum)
        }
    }
    
    private func _buildAlbum(album: Album) {
        if let theFirstTrack = album.ITTracks.first {
            if theFirstTrack.hasArtworkAvailable {
                //let theArtwork = theFirstTrack.artwork
                imageView?.image = theFirstTrack.artwork?.image
            } else {
                imageView?.image = NSImage(named: "album-icon")
            }
        }
        /*if ((theFirstTrack?.hasArtworkAvailable) != nil) {
            
        } else {
            imageView?.image = NSImage(named: "album-icon")
        }*/
    }
    
    private func _buildPlaylist(playlist: Playlist) {
        if playlist.isFolder {
            imageView?.image = NSImage(named: "folder-playlist-icon")
        } else if playlist.isSmart {
            imageView?.image = NSImage(named: "smart-playlist-icon")
        } else {
            imageView?.image = NSImage(named: "normal-playlist-icon")
        }
    }
    
}
