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
        
        initBounds()
        validate()
    }
    
    override var value: Any? {
        set {
            if newValue != nil {
                thePathsBrowsed = newValue as! [URL]
                _setInfos()
            } else {
                if thePathsBrowsed != nil {
                    thePathsBrowsed = [URL]()
                    _setInfos()
                }
            }
        }
        get {
            if thePathsBrowsed != nil && (thePathsBrowsed?.count)! > 0 {
                return thePathsBrowsed
            }
            return nil
        }
    }
    
    var freeSpace: UInt64? {
        get {
            if (thePathsBrowsed?.count)! == 1 {
                let theFreeSpace: UInt64 = UInt64(FileManager.getFreeSpace(thePath: thePathsBrowsed![0])!)
                return theFreeSpace
            }
            return nil
        }
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
        delegate.browse(browsePathFormView: self)
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
