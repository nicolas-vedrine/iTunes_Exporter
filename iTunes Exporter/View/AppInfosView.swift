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
    @IBOutlet weak var trackNameLabel: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    public static var exportingStatus: String = "Exporting..."
    
    private var _playlistElements = [NSView]()
    private var _exportElements = [NSView]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        _initElements()
        
        if nItemsLabel != nil {
            setName(name: "Sélectionnez une playlist...", isPlaceHolder: true)
            durationLabel.isHidden = true
            nItemsLabel.isHidden = true
            sizeLabel.isHidden = true
            trackNameLabel.isHidden = true
            statusLabel.isHidden = true
            
            theState = AppInfosViewState.playlistInfo.rawValue
        }
    }
    
    func setProgress(current: Double, total: Double) {
        let percent: Double = current / total * 100
        self.progressBar.doubleValue = percent
        //print("V&G_Project___setProgress : ", current, total, Double(current / total * 100))
    }
    
    func setDuration(duration: Int) {
        durationLabel.isHidden = false
        //print("V&G_Project___setDuration : ", duration)
        let formattedDuration: String =  "Durée totale : " + duration.toFormattedDuration(unitsStyle: .abbreviated) // OK
        durationLabel.stringValue = formattedDuration
    }
    
    func setName(name: String, isPlaceHolder: Bool = false) {
        self.playlistNameLabel.placeholderString = name
        if !isPlaceHolder {
            self.playlistNameLabel.stringValue = "Nom de la playlist : " + name
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
    
    func setTrackName(theTrackName: String) {
        trackNameLabel.stringValue = theTrackName
    }
    
    func setStatus(theStatus: String) {
        statusLabel.isHidden = false
        statusLabel.stringValue = theStatus
    }
    
    private func _initElements() {
        _playlistElements.append(nItemsLabel)
        _playlistElements.append(durationLabel)
        //_playlistElements
    }
    
    override var state: String {
        set {
            theState = newValue
            switch newValue {
            case AppInfosViewState.playlistInfo.rawValue:
                nItemsLabel.isHidden = false
                durationLabel.isHidden = false
                playlistNameLabel.isHidden = false
                sizeLabel.isHidden = false
                trackNameLabel.isHidden = true
                statusLabel.isHidden = true
                progressBar.isHidden = true
            case AppInfosViewState.exporting.rawValue:
                nItemsLabel.isHidden = true
                durationLabel.isHidden = true
                playlistNameLabel.isHidden = true
                sizeLabel.isHidden = true
                trackNameLabel.isHidden = false
                statusLabel.isHidden = false
                progressBar.isHidden = false
            default:
                print("V&G_Project___state default : ", self)
            }
        }
        get {
            return theState!
        }
    }
}

enum AppInfosViewState: String {
    case playlistInfo = "playlistInfo"
    case artistInfo = "artistInfo"
    case exporting = "exporting"
}
