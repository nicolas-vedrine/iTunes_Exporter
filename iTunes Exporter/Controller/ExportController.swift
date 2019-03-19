//
//  ExportController.swift
//  iTunes Exporter
//
//  Created by Developer on 20/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class ExportController: BaseProjectViewController {

    //@IBOutlet weak var theBrowsePathTextInput: NSTextField!
    //@IBOutlet weak var theBrowseButton: NSButton!
    @IBOutlet weak var theSpaceRequiredLabel: NSTextField!
    @IBOutlet weak var theProceedButton: NSButton!
    @IBOutlet weak var theFreeSpaceLabel: NSTextField!
    //@IBOutlet weak var theFileNameComboBox: NSComboBox!
    //@IBOutlet weak var theIfAlreadyExistsComboBox: NSComboBox!
    
    @IBOutlet var theExportFormView: ExportFormView!
    @IBOutlet weak var theBrowsePathFormView: VGBrowsePathFormView!
    @IBOutlet weak var theFileNameComboBoxFormView: VGComboBoxFormView!
    @IBOutlet weak var theIfAlreadyExistsComboBoxFormView: VGComboBoxFormView!
    
    private var _theTracks: [Track]?
    
    private var _theChoosenPath: URL?
    private var _theFilesSize: UInt64 = 0
    
    private var _theFileNameComboBoxDataSource: NSMutableArray = []
    //private var _theChosenFileNameType: FileNameComboBoxType?
    
    private var _theIfAlreayExistsComboBoxDataSource: NSMutableArray = []
    //private var _theChosenIfAlreadyExistsType: IfAlreadyExistsComboBoxType?
    
    override func buildView() {
        super.buildView()
        
        if let theData = data {
            print("V&G_Project___buildView : ", theData)
            _theTracks = data as? [Track]
            _buildFormView()
            _setSpaceRequired()
            //_buildBrowse()
        }
    }
    
    private func _buildFormView() {
        theExportFormView.delegate = self
        
        theBrowsePathFormView.browsePathFormType = .folder
        theBrowsePathFormView.textLabel = "Export folder* :"
        theBrowsePathFormView.browseButton.title = "Parcourir..."
        theBrowsePathFormView.delegate = self
        
        theFileNameComboBoxFormView.textLabel = "File name* :"
        theFileNameComboBoxFormView.dataSource = _getFileNameComboBoxFormViewDataSource()
        
        theIfAlreadyExistsComboBoxFormView.textLabel = "If already exists* :"
        theIfAlreadyExistsComboBoxFormView.dataSource = _getIfAlreadyExistsComboBoxFormViewDataSource()
        
        theExportFormView.addItem(componentForm: theBrowsePathFormView, code: FormItemCode.exportTo.rawValue)
        theExportFormView.addItem(componentForm: theFileNameComboBoxFormView, code: FormItemCode.fileName.rawValue)
        theExportFormView.addItem(componentForm: theIfAlreadyExistsComboBoxFormView, code: FormItemCode.ifAlreadyExists.rawValue)
        
        for item in theExportFormView.getItems() {
            let componentFormView: VGBaseComponentFormView = item as! VGBaseComponentFormView
            componentFormView.superview?.wantsLayer = true
            componentFormView.layer?.masksToBounds = false
            //dump(componentFormView.constraints)
            if let leading = componentFormView.getConstraint(byIdentifier: "leading") {
                leading.constant = 0
            }
        }
        
        /*theExportFormView.paddingRight = 5
        theExportFormView.paddingLeft = 100*/
    }
    
    /*private func _buildBrowse() {
        
    }*/
    
    private func _getFileNameComboBoxFormViewDataSource() -> [VGBaseDataFormStruct] {
        var theDataSource: [VGBaseDataFormStruct] = [VGBaseDataFormStruct]()
        
        let fileName = VGBaseDataFormStruct(label: "<nom de fichier>", data: FileNameComboBoxType.fileName)
        theDataSource.append(fileName)
        
        let artistSepAlbumSlashFileName = VGBaseDataFormStruct(label: "<artist> - <album> / <file name>", data: FileNameComboBoxType.artistSepAlbumSlashFileName)
        theDataSource.append(artistSepAlbumSlashFileName)
        
        let artistSlashAlbumSlashFileName = VGBaseDataFormStruct(label: "<artist> / <album> / <file name>", data: FileNameComboBoxType.artistSlashAlbumSlashFileName)
        theDataSource.append(artistSlashAlbumSlashFileName)
        
        let albumSlashFileName = VGBaseDataFormStruct(label: "<album> / <file name>", data: FileNameComboBoxType.albumSlashFileName)
        theDataSource.append(albumSlashFileName)
        
        let artistSlashFileName = VGBaseDataFormStruct(label: "<artist> / <file name>", data: FileNameComboBoxType.artistSlashFileName)
        theDataSource.append(artistSlashFileName)
        
        //_theFileNameComboBoxDataSource = NSMutableArray(array: theDataSource)
        
        //_setComboBox(theComboBox: theFileNameComboBox)
        
        return theDataSource
    }
    
    private func _getIfAlreadyExistsComboBoxFormViewDataSource() -> [VGBaseDataFormStruct] {
        var theDataSource: [VGBaseDataFormStruct] = [VGBaseDataFormStruct]()
        
        let overwrite = VGBaseDataFormStruct(label: "overwrite", data: IfAlreadyExistsComboBoxType.overwrite)
        theDataSource.append(overwrite)
        
        let keepBoth = VGBaseDataFormStruct(label: "keep both", data: IfAlreadyExistsComboBoxType.keepBoth)
        theDataSource.append(keepBoth)
        
        //_theIfAlreayExistsComboBoxDataSource = NSMutableArray(array: theDataSource)
        
        //_setComboBox(theComboBox: theIfAlreadyExistsComboBox)
        
        return theDataSource
    }
    
    private func _setComboBox(theComboBox: NSComboBox) {
        theComboBox.usesDataSource = true
        theComboBox.delegate = self
        theComboBox.dataSource = self
        
        theComboBox.isEditable = false
        theComboBox.selectItem(at: 0)
    }
    
    private func _setSpaceRequired() {
        _theFilesSize = _getFilesSize()
        theSpaceRequiredLabel.stringValue = "Space required: " + _theFilesSize.toMegaBytes()
    }
    
    private func _setFreeSpace(thePath: URL) {
        let theFreeSpace: UInt64 = UInt64(FileManager.getFreeSpace(thePath: thePath)!)
        theFreeSpaceLabel.stringValue = "Free space : " + theFreeSpace.toMegaBytes()
    }
    
    private func _getFilesSize() -> UInt64 {
        var theFilesSize: UInt64 = 0
        for track in _theTracks! {
            theFilesSize += track.size
        }
        return theFilesSize
    }
    
    @IBAction func theBrowseAction(_ sender: Any) {
        let theBrowsePanel: NSOpenPanel = NSOpenPanel()
        theBrowsePanel.delegate = self as? NSOpenSavePanelDelegate
        theBrowsePanel.allowsMultipleSelection = false
        theBrowsePanel.canChooseFiles = false
        theBrowsePanel.canChooseDirectories = true
        theBrowsePanel.runModal()
        
        _theChoosenPath = theBrowsePanel.url!
        if let theChoosenPath = _theChoosenPath {
            //theBrowsePathTextInput.stringValue = theChoosenPath.absoluteString
            _setFreeSpace(thePath: theChoosenPath)
            if FileManager.hasEnoughSpace(thePath: theChoosenPath, theSize: _theFilesSize) {
                theProceedButton.isEnabled = true
            } else {
                theFreeSpaceLabel.stringValue += " (!!!)"
            }
        }
    }
    
    
    @IBAction func theProceedAction(_ sender: Any) {
        //let theChosenIfAlreadyExistsType: IfAlreadyExistsComboBoxType = _getChosenIfAlreadyExists()
        theExportFormView.check()
    }
    
    private func _getSourcePath(theTrack: Track) -> String {
        let theITTrack: ITLibMediaItem = theTrack.theITTrack
        let theSourceURL: URL = theITTrack.location!
        return theSourceURL.path
    }
    
    /*private func _getDestinationPath(theTrack: Track) -> String {
        let theChosenFileNameType: FileNameComboBoxType = _getChosenFileName()
        let theChosenPath: String = (_theChoosenPath?.path)! + "/"
        let theITTrack: ITLibMediaItem = theTrack.theITTrack
        let theSourceURL: URL = theITTrack.location!
        let theFileName: String = theSourceURL.lastPathComponent
        
        var theArtistName: String = "unknown artist"
        if let theITArtistName = theITTrack.artist?.name {
            theArtistName = theITArtistName
        }
        var theAlbumTitle: String = "unknow album"
        if let theITAlbumName = theITTrack.album.title {
            theAlbumTitle = theITAlbumName
        }
        
        var theDestinationPath: String = theChosenPath
        switch theChosenFileNameType {
        case FileNameComboBoxType.fileName:
            theDestinationPath += theFileName
        case FileNameComboBoxType.artistSlashAlbumSlashFileName:
            theDestinationPath += theArtistName + "/" + theAlbumTitle + "/" + theFileName
        case FileNameComboBoxType.albumSlashFileName:
            theDestinationPath += theAlbumTitle + "/" + theFileName
        case FileNameComboBoxType.artistSepAlbumSlashFileName:
            theDestinationPath += theArtistName + " - " + theAlbumTitle + "/" + theFileName
        case FileNameComboBoxType.artistSlashFileName:
            theDestinationPath += theArtistName + "/" + theFileName
        }
        return theDestinationPath
    }*/
    
    /*private func _getChosenFileName() -> FileNameComboBoxType {
        let theItem: VGBaseDataFormStruct = _theFileNameComboBoxDataSource[theFileNameComboBox.indexOfSelectedItem] as! VGBaseDataFormStruct
        return theItem.data as! FileNameComboBoxType
    }*/
    
    /*private func _getChosenIfAlreadyExists() -> IfAlreadyExistsComboBoxType {
        let theItem: VGBaseDataFormStruct = _theIfAlreayExistsComboBoxDataSource[theIfAlreadyExistsComboBox.indexOfSelectedItem] as! VGBaseFormObject
        return theItem.data as! IfAlreadyExistsComboBoxType
    }*/
    
}

extension ExportController: VGBrowsePathFormViewDelegate {
    
    func browse(browsePathFormView: VGBrowsePathFormView) {
        let theBrowsePanel: NSOpenPanel = NSOpenPanel()
        theBrowsePanel.delegate = self as? NSOpenSavePanelDelegate
        theBrowsePanel.title = "Choose your export folder..."
        theBrowsePanel.allowsMultipleSelection = false
        let canChooseFiles: Bool = false
        theBrowsePanel.canChooseFiles = canChooseFiles
        theBrowsePanel.canChooseDirectories = !canChooseFiles
        
        if theBrowsePanel.runModal() == NSApplication.ModalResponse.OK {
            browsePathFormView.value = [theBrowsePanel.url]
            print("V&G_Project___browse : ", self, browsePathFormView.value)
        }
    }
    
}

extension ExportController: VGFormViewDelegate {
    func validatedForm(form: VGFormView, value: [String : Any]) {
        print("V&G_Project___validatedForm : ", self, value)
    }
    
    func invalidatedForm(form: VGFormView, errorFormItems: [VGBaseFormItem]) {
        print("V&G_Project___invalidatedForm : ", self, errorFormItems)
    }
}

extension ExportController: NSComboBoxDelegate, NSComboBoxDataSource {
    
    /*func numberOfItems(in comboBox: NSComboBox) -> Int {
        var theCount: Int?
        if comboBox == theFileNameComboBox {
            theCount = _theFileNameComboBoxDataSource.count
        } else if comboBox == theIfAlreadyExistsComboBox {
                theCount = _theIfAlreayExistsComboBoxDataSource.count
        }
        return theCount!
    }*/
    
    /*func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        var theItem: VGBaseFormObject?
        if comboBox == theFileNameComboBox {
            theItem = _theFileNameComboBoxDataSource[index] as? VGBaseFormObject
        } else if comboBox == theIfAlreadyExistsComboBox {
            theItem = _theIfAlreayExistsComboBoxDataSource[index] as? VGBaseFormObject
        }
        return theItem!.label
    }*/
    
}

enum FormItemCode: String {
    case exportTo = "exportTo"
    case fileName = "fileName"
    case ifAlreadyExists = "ifAlreadyExists"
}

enum FileNameComboBoxType: String {
    case fileName = "file_name"
    case artistSepAlbumSlashFileName = "artist-album/file_name"
    case artistSlashAlbumSlashFileName = "<artist>/<album>/<file_name>"
    case albumSlashFileName = "<album>/<file name>"
    case artistSlashFileName = "<artist>/<file name>"
}

enum IfAlreadyExistsComboBoxType: String {
    case overwrite = "overwrite"
    case keepBoth = "keep_both"
    case ignore = "ignore"
    case ignoreOnlyIfMoreRecent = "ignoreOnlyIfMoreRecent"
}
