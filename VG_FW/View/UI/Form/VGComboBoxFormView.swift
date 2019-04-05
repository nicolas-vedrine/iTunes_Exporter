//
//  ComboBoxFormView.swift
//  TestForm
//
//  Created by Developer on 14/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class VGComboBoxFormView: VGBaseUIComponentWrapper, VGLoadableNib {
    
    @IBOutlet var contentView: NSView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var comboBox: NSComboBox!
    @IBOutlet weak var paddingRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paddingLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var gapConstraint: NSLayoutConstraint!
    @IBOutlet weak var box: NSBox!
    
    internal var theDataSource: NSMutableArray?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadViewFromNib()
        
        theBox = box
        theLabel = label
        theUIComponent = comboBox
        thePaddingRightConstraint = paddingRightConstraint
        thePaddingLeftConstraint = paddingLeftConstraint
        gapConstraint.constant = theGap
        theGapConstraints.append(gapConstraint)
        
        initBounds()
        validate()
    }
    
    internal func setComboBox() {
        comboBox.dataSource = self
        comboBox.isEditable = false
    }
    
    var dataSource: [VGBaseDataForm] {
        set {
            theDataSource = NSMutableArray(array: newValue)
            comboBox.usesDataSource = true
            comboBox.delegate = self
        }
        get {
            return theDataSource!.copy() as! [VGBaseDataForm]
        }
    }
    
    override var value: Any? {
        get {
            let theIndex: Int = comboBox.indexOfSelectedItem
            if theIndex > -1, let theItem: VGBaseDataForm = theDataSource![theIndex] as? VGBaseDataForm {
                return theItem.data
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                if comboBox.dataSource == nil {
                    setComboBox()
                }
                var theDataFormStruct: VGBaseDataForm
                var theIndex: Int
                if newValue is VGBaseDataForm {
                    theDataFormStruct = newValue as! VGBaseDataForm
                    theIndex = dataSource.index(where: {$0.label == theDataFormStruct.label})!
                    comboBox.selectItem(at: theIndex)
                    super.value = theIndex
                } else if newValue is Int {
                    theIndex = newValue as! Int
                    theDataFormStruct = theDataSource![theIndex] as! VGBaseDataForm
                    comboBox.selectItem(at: theIndex)
                    super.value = theIndex
                }
                print("V&G_FW___value : ", self, value)
            } else {
                if comboBox.indexOfSelectedItem > -1 {
                    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
                }
            }
        }
    }
    
}

extension VGComboBoxFormView: NSComboBoxDelegate, NSComboBoxDataSource {
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return theDataSource!.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let theItem = theDataSource![index] as? VGBaseDataForm
        return theItem!.label
    }
    
    func comboBoxWillPopUp(_ notification: Notification) {
        let theComboBox: NSComboBox = notification.object as! NSComboBox
        if theComboBox == comboBox && theComboBox.dataSource == nil  {
            setComboBox()
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let cbo: NSComboBox = notification.object as! NSComboBox
        if cbo == comboBox {
            let theIndex: Int = comboBox.indexOfSelectedItem
            if theIndex > -1, let theItem: VGBaseDataForm = theDataSource![theIndex] as? VGBaseDataForm {
                super.value = theIndex
            }
        }
    }
    
}

