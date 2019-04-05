//
//  VGBrowsePathFormView.swift
//  TestForm
//
//  Created by Developer on 15/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class VGBrowsePathFormView: VGBaseUIComponentWrapper, VGLoadableNib {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var paddingLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var gapConstraint1: NSLayoutConstraint!
    @IBOutlet weak var gapConstraint2: NSLayoutConstraint!
    @IBOutlet weak var paddingRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var pathTextInput: NSTextField!
    @IBOutlet weak var browseButton: NSButton!
    
    internal var thePathsBrowsed: [URL]?
    
    var browsePathFormType: VGBrowsePathFormType = VGBrowsePathFormType.file
    var browsePathFormStyle: VGBrowsePathFormStyle = VGBrowsePathFormStyle.short
    
    var delegate: VGBrowsePathFormViewDelegate!
    
    var allowsMultipleSelection: Bool = false
    var multipleText: String = "Multiple selection... Roll over for more details."
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        theBox = box
        theLabel = label
        theUIComponent = pathTextInput
        pathTextInput.isEditable = false
        thePaddingRightConstraint = paddingRightConstraint
        thePaddingLeftConstraint = paddingLeftConstraint
        gapConstraint1.constant = theGap
        gapConstraint2.constant = theGap
        theGapConstraints.append(gapConstraint1)
        theGapConstraints.append(gapConstraint2)
        
        isSetUserDefaultsValue = true
        initBounds()
        validate()
    }
    
    override var value: Any? {
        set {
            if newValue != nil {
                if newValue is URL {
                    thePathsBrowsed = [URL]()
                    let theURL: URL = newValue as! URL
                    thePathsBrowsed?.append(theURL)
                } else if newValue is [URL] {
                    thePathsBrowsed = newValue as! [URL]
                } else if newValue is String {
                    thePathsBrowsed = [URL]()
                    let theURL: URL = URL(fileURLWithPath: newValue as! String)
                    thePathsBrowsed?.append(theURL)
                } else {
                    fatalError("newValue of VGBrowsePathFormView must be [URL] or URL")
                    return
                }
                _setInfos()
                super.value = newValue
            } else {
                if thePathsBrowsed != nil {
                    thePathsBrowsed = [URL]()
                    _setInfos()
                }
            }
        }
        get {
            if thePathsBrowsed != nil && (thePathsBrowsed?.count)! > 0 {
                if allowsMultipleSelection {
                    return thePathsBrowsed
                } else {
                    return thePathsBrowsed![0]
                }
            }
            return nil
        }
    }
    
    var URLFreeSpace: Int64? {
        get {
            if let theValue = value {
                if theValue is URL {
                    let theValueURL: URL = theValue as! URL
                    return FileManager.getFreeSpace(thePath: theValueURL)
                }
            }
            return nil
        }
    }
    
    func getFolderContent(fileManager: FileManager = FileManager.default) -> [URL] {
        var theFilesList = [URL]()
        let theURL: URL = value as! URL
        let thePath: String = theURL.path
        let en=fileManager.enumerator(atPath: thePath)
        
        while let element = en?.nextObject() as? String {
            let theItemURL: URL = URL(fileURLWithPath: thePath + "/" + element)
            theFilesList.append(theItemURL)
        }
        return theFilesList
    }
    
    private func _setInfos() {
        var pathTextInputStr: String = ""
        var toolTipStr: String = ""
        if (thePathsBrowsed?.count)! > 1 {
            pathTextInputStr = multipleText
            for url in thePathsBrowsed! {
                toolTipStr += url.path
                if (thePathsBrowsed?.index(of: url))! < (thePathsBrowsed?.count)! - 1 {
                    toolTipStr += "\n"
                }
            }
        } else if (thePathsBrowsed?.count)! == 1 {
            let thePathURL = thePathsBrowsed![0]
            let theName: String = browsePathFormStyle == VGBrowsePathFormStyle.short ? thePathURL.getName()! : thePathURL.path
            pathTextInputStr = theName
            toolTipStr = thePathsBrowsed![0].path
        }
        if pathTextInputStr == multipleText {
            pathTextInput.stringValue = ""
            pathTextInput.placeholderString = pathTextInputStr
        } else {
            pathTextInput.placeholderString = ""
            pathTextInput.stringValue = pathTextInputStr
        }
        pathTextInput.toolTip = toolTipStr
    }
    
    @IBAction func browseAction(_ sender: Any) {
        browse()
    }
    
    func browse() {
        if delegate != nil {
            delegate.browse(browsePathFormView: self)
        }
    }
    
}

protocol VGBrowsePathFormViewDelegate {
    func browse(browsePathFormView: VGBrowsePathFormView)
}

enum VGBrowsePathFormType: String {
    case file = "file"
    case folder = "folder"
}

enum VGBrowsePathFormStyle: Int {
    case short = 0
    case long = 1
}
