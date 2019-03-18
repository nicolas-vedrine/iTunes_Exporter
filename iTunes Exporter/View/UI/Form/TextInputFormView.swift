//
//  TextInputFormView.swift
//  TestForm
//
//  Created by Developer on 12/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class TextInputFormView: VGBaseTextComponentFormView, VGLoadableNib {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var textInput: NSTextField!
    @IBOutlet weak var paddingRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paddingLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var gapConstraint: NSLayoutConstraint!
    @IBOutlet weak var box: NSBox!
    
    internal var theIsSecure: Bool = false
    
    var isSecure: Bool {
        set {
            self.theIsSecure = newValue
            textInput.cell = getCell(isSecure: self.theIsSecure)
        }
        get {
            return theIsSecure
        }
    }
    
    private func getCell(isSecure: Bool) -> NSTextFieldCell {
        let cell: NSTextFieldCell = isSecure ? NSSecureTextFieldCell(textCell: "") : NSTextFieldCell(textCell: "")
        cell.isBordered = true
        cell.backgroundColor = .white
        cell.isBezeled = true
        cell.bezelStyle = .squareBezel
        cell.isEnabled = true
        cell.isEditable = true
        cell.isSelectable = true
        if cell is NSSecureTextFieldCell {
            let secureCell:NSSecureTextFieldCell = cell as! NSSecureTextFieldCell
            secureCell.echosBullets = true
        }
        print("V&G_FW___<#name#> : ", isSecure)
        return cell
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        print("V&G_FW___draw tiaiai : ", self)
        
    }
    
   override var wantsDefaultClipping:Bool{return false}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()

        theBox = box
        theLabel = label
        theTextComponent = textInput
        thePaddingRightConstraint = paddingRightConstraint
        thePaddingLeftConstraint = paddingLeftConstraint
        gapConstraint.constant = theGap
        theGapConstraints.append(gapConstraint)
        
        initBounds()
        validate()
    }
    
}
