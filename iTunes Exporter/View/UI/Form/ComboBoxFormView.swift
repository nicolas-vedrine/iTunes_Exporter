//
//  ComboBoxFormView.swift
//  TestForm
//
//  Created by Developer on 14/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

@IBDesignable class ComboBoxFormView: VGBaseUIComponentWrapper, VGLoadableNib {
    
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
    
    var dataSource: [VGBaseDataFormStruct] {
        set {
            theDataSource = NSMutableArray(array: newValue)
            comboBox.usesDataSource = true
            comboBox.delegate = self
        }
        get {
            return theDataSource!.copy() as! [VGBaseDataFormStruct]
        }
    }
    
    override var value: Any? {
        get {
            let theIndex: Int = comboBox.indexOfSelectedItem
            if theIndex > -1, let theItem: VGBaseDataFormStruct = theDataSource![theIndex] as? VGBaseDataFormStruct {
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
                let theDataFormStruct: VGBaseDataFormStruct = newValue as! VGBaseDataFormStruct
                let theIndex: Int = dataSource.index(where: {$0.label == theDataFormStruct.label})!
                comboBox.selectItem(at: theIndex)
                super.value = theDataFormStruct.data
                print("V&G_FW___value : ", self, value)
            } else {
                if comboBox.indexOfSelectedItem > -1 {
                    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
                }
            }
        }
    }
    
}

extension ComboBoxFormView: NSComboBoxDelegate, NSComboBoxDataSource {
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return theDataSource!.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let theItem = theDataSource![index] as? VGBaseDataFormStruct
        return theItem!.label
    }
    
    func comboBoxWillPopUp(_ notification: Notification) {
        let theComboBox: NSComboBox = notification.object as! NSComboBox
        if theComboBox == comboBox && theComboBox.dataSource == nil  {
            setComboBox()
        }
    }
    
}

