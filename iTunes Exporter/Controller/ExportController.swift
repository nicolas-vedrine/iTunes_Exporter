//
//  ExportController.swift
//  iTunes Exporter
//
//  Created by Developer on 20/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

class ExportController: BaseProjectViewController {

    @IBOutlet weak var theSpaceRequiredLabel: NSTextField!
    @IBOutlet weak var theProceedButton: NSButton!
    @IBOutlet weak var theFreeSpaceLabel: NSTextField!
    @IBOutlet var theExportFormView: ExportFormView!
    @IBOutlet weak var theBrowsePathFormView: VGBrowsePathFormView!
    @IBOutlet weak var theFileNameComboBoxFormView: VGComboBoxFormView!
    @IBOutlet weak var theIfAlreadyExistsComboBoxFormView: VGComboBoxFormView!
    
    private var _theTracks: [Track]?
    private var _theFilesSize: UInt64 = 0
    
    var onValidateForm: ((_ formResult: [String: Any]) -> ())?
    
    override func buildView() {
        super.buildView()
        
        if let theData = data {
            print("V&G_Project___buildView : ", theData)
            _theTracks = data as? [Track]
            _buildFormView()
            _setSpaceRequired()
        }
    }
    
    private func _buildFormView() {
        theExportFormView.delegate = self
        
        theBrowsePathFormView.browsePathFormStyle = .long
        theBrowsePathFormView.browsePathFormType = .folder
        theBrowsePathFormView.textLabel = "Export folder* :"
        theBrowsePathFormView.browseButton.title = "Parcourir..."
        theBrowsePathFormView.pathTextInput.placeholderString = "Please select a folder..."
        theBrowsePathFormView.delegate = self
        
        theFileNameComboBoxFormView.textLabel = "File name* :"
        theFileNameComboBoxFormView.dataSource = _getFileNameComboBoxFormViewDataSource()
        theFileNameComboBoxFormView.isSetUserDefaultsValue = true
        theFileNameComboBoxFormView.comboBox.placeholderString = "Please select..."
        
        theIfAlreadyExistsComboBoxFormView.textLabel = "If already exists* :"
        theIfAlreadyExistsComboBoxFormView.dataSource = _getIfAlreadyExistsComboBoxFormViewDataSource()
        theIfAlreadyExistsComboBoxFormView.isSetUserDefaultsValue = true
        theIfAlreadyExistsComboBoxFormView.comboBox.placeholderString = "Please select..."
        
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
        theExportFormView.defaultButton = theProceedButton
        //theExportFormView.isAutoFill = true
    }
    
    private func _getFileNameComboBoxFormViewDataSource() -> [VGBaseDataForm] {
        let theDataSource = DataSources.getFileNameDataSource()
        return theDataSource
    }
    
    private func _getIfAlreadyExistsComboBoxFormViewDataSource() -> [VGBaseDataForm] {
        let theDataSource = DataSources.getIfAlreadyExistsDataSource()
        return theDataSource
    }
    
    private func _setSpaceRequired() {
        _theFilesSize = _getFilesSize()
        theSpaceRequiredLabel.stringValue = "Space required: " + _theFilesSize.toMegaBytes()
    }
    
    private func _setFreeSpace(browsePathFormView: VGBrowsePathFormView) {
        let theFreeSpace: UInt64 = UInt64(bitPattern: browsePathFormView.URLFreeSpace!)
        theFreeSpaceLabel.stringValue = "Free space : " + theFreeSpace.toMegaBytes()
    }
    
    private func _getFilesSize() -> UInt64 {
        var theFilesSize: UInt64 = 0
        for track in _theTracks! {
            theFilesSize += track.size
        }
        return theFilesSize
    }
    
    @IBAction func theProceedAction(_ sender: Any) {
        theExportFormView.check()
    }
    
    private func _getSourcePath(theTrack: Track) -> String {
        let theITTrack: ITLibMediaItem = theTrack.theITTrack
        let theSourceURL: URL = theITTrack.location!
        return theSourceURL.path
    }
    
}

extension ExportController: VGBrowsePathFormViewDelegate {
    
    /*func browse(browsePathFormView: VGBrowsePathFormView) {
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
            _setFreeSpace(browsePathFormView: browsePathFormView)
        }
    }*/
    
    func browse(browsePathFormView: VGBrowsePathFormView) {
        DispatchQueue.main.async { [unowned self] in
            let theBrowsePanel: NSOpenPanel = NSOpenPanel()
            theBrowsePanel.delegate = self as? NSOpenSavePanelDelegate
            theBrowsePanel.allowsMultipleSelection = browsePathFormView.allowsMultipleSelection
            let canChooseFiles: Bool = browsePathFormView.browsePathFormType == .file ? true : false
            theBrowsePanel.canChooseFiles = canChooseFiles
            theBrowsePanel.canChooseDirectories = !canChooseFiles
            theBrowsePanel.title = "Choose your export folder..."
            if theBrowsePanel.runModal() == .OK {
                browsePathFormView.value = theBrowsePanel.url
                self._setFreeSpace(browsePathFormView: browsePathFormView)
            }
        }
    }
    
}

extension ExportController: VGFormViewDelegate {
    func validatedForm(form: VGFormView, value: [String : Any]) {
        print("V&G_Project___validatedForm : ", self, value)
        dismiss(self)
    }
    
    func invalidatedForm(form: VGFormView, errorFormItems: [VGBaseFormItem]) {
        print("V&G_Project___invalidatedForm : ", self, errorFormItems)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        if theExportFormView.isValid! {
            onValidateForm?(theExportFormView.formResult!)
            theExportFormView.clear()
        }
    }
}
