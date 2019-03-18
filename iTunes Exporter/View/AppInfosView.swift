//
//  AppInfos.swift
//  iTunes Exporter
//
//  Created by Developer on 18/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class AppInfosView: VGBaseNSView, VGLoadableNib {
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var nItemsLabel: NSTextField!
    @IBOutlet weak var playlistNameLabel: NSTextField!
    @IBOutlet weak var durationLabel: NSTextField!
    @IBOutlet weak var sizeLabel: NSTextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        if nItemsLabel != nil {
            setPlaylistName(playlistName: "Sélectionnez une playlist...", isPlaceHolder: true)
            durationLabel.isHidden = true
            nItemsLabel.isHidden = true
            sizeLabel.isHidden = true
        }
    }
    
    func setProgress(current: Double, total: Double) {
        let percent: Double = current / total * 100
        self.progressBar.doubleValue = percent
        print("V&G_Project___<#name#> : ", current, total, Double(current / total * 100))
    }
    
    func setPlaylistDuration(duration: Int) {
        durationLabel.isHidden = false
        let formattedDuration: String =  "Durée totale : " + Int(duration / 1000).toFormattedDuration()
        durationLabel.stringValue = formattedDuration
    }
    
    func setPlaylistName(playlistName: String, isPlaceHolder: Bool = false) {
        self.playlistNameLabel.placeholderString = playlistName
        if !isPlaceHolder {
            self.playlistNameLabel.stringValue = "Nom de la playlist : " + playlistName
        }
    }
    
    func setCountItems(countItems: Int) {
        nItemsLabel.isHidden = false
        nItemsLabel.stringValue = "Nombre d'éléments : " + countItems.toFormattedNumber()
    }
    
    func setSize(size: UInt64) {
        sizeLabel.isHidden = false
        sizeLabel.stringValue = "Taille : " + size.toMegaBytes()
    }
    
}
