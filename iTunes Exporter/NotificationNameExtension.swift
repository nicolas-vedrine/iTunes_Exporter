//
//  NotificationNameExtension.swift
//  iTunes Exporter
//
//  Created by Developer on 15/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let ARTIST_TREE_LOADING = Notification.Name(rawValue: "fr.videoandgo.iTunesExporter.artistTreeLoading")
    static let TRACKS_ADDED = Notification.Name(rawValue: "fr.videoandgo.iTunesExporter.tracksAdded")
    static let TRACKS_DELETED = Notification.Name(rawValue: "fr.videoandgo.iTunesExporter.tracksDeleted")
    
}
