//
//  VGForm.swift
//  TestForm
//
//  Created by Developer on 12/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Cocoa

protocol VGFormProtocol {
    
    var isValid: Bool? {get}
    var value: Any? {get set}
    var paddingRight: CGFloat {get set}
    var paddingLeft: CGFloat {get set}
    var gap: CGFloat {get set}
    
    func check()
    func validate()
    func invalidate()
    func clear()
    
}

protocol VGFormViewDelegate {
    func validatedForm(form: VGFormView, value: [String : Any])
    func invalidatedForm(form: VGFormView, errorFormItems: [VGBaseFormItem])
}

@IBDesignable class VGFormView: VGBaseNSView, VGFormProtocol {
    
    var isValid: Bool?
    var value: Any?
    var isAutoClear: Bool = true
    private var _theIsAutoFill: Bool = false
    
    var delegate: VGFormViewDelegate!
    
    internal var theDefaultButton: NSButton!
    internal var theFormItems: [String : VGBaseFormItem] = [String : VGBaseFormItem]()
    internal var theValidationMode: VGFormValidationMode = VGFormValidationMode.check
    internal var thePaddingLeft: CGFloat = 0.0
    internal var thePaddingRight: CGFloat = 0.0
    internal var theGap: CGFloat = 5
    
    @IBInspectable var isAutoFill: Bool {
        set {
            _theIsAutoFill = newValue
            if _theIsAutoFill {
                for formItem: VGBaseFormItem in theFormItems.values {
                    let componentForm: VGFormProtocol = formItem.componentForm
                    if componentForm is VGBaseComponentFormView {
                        let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
                        let defaultValue: String = formItem.code
                        _fillComponentFormView(componentFormView: componentFormView, defaultValue: defaultValue)
                    }
                }
            } else {
                clear()
            }
        }
        get {
            return _theIsAutoFill
        }
    }
    
    private func _fillComponentFormView(componentFormView: VGBaseComponentFormView, defaultValue: String) {
        if componentFormView is VGBaseTextComponentFormView {
            let textComponentFormView: VGBaseTextComponentFormView = componentFormView as! VGBaseTextComponentFormView
            textComponentFormView.value = defaultValue
        } else if componentFormView is VGComboBoxFormView {
            let comboBoxFormView: VGComboBoxFormView = componentFormView as! VGComboBoxFormView
            let dataSource = comboBoxFormView.dataSource
            comboBoxFormView.value = dataSource[dataSource.count - 1]
        } else if componentFormView is VGBaseGroupFormView {
            let groupFormView: VGBaseGroupFormView = componentFormView as! VGBaseGroupFormView
            for item in groupFormView.items! {
                _fillComponentFormView(componentFormView: item, defaultValue: defaultValue)
            }
        } else if componentFormView is VGBrowsePathFormView {
            let browsePathFormView: VGBrowsePathFormView = componentFormView as! VGBrowsePathFormView
            var theURLs: [URL] = [URL]()
            let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
            let userDesktopDirectory = paths[0]
            let userDesktopUrl: URL = URL(fileURLWithPath: userDesktopDirectory)
            theURLs.append(userDesktopUrl)
            browsePathFormView.value = theURLs
        }
    }
    
    @IBInspectable var paddingRight: CGFloat {
        set {
            for formItem: VGBaseFormItem in theFormItems.values {
                let componentForm: VGFormProtocol = formItem.componentForm
                if componentForm is VGBaseComponentFormView {
                    let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
                    componentFormView.paddingRight = newValue
                }
            }
            thePaddingRight = newValue
        }
        get {
            return thePaddingRight
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat {
        set {
            for formItem: VGBaseFormItem in theFormItems.values {
                let componentForm: VGFormProtocol = formItem.componentForm
                if componentForm is VGBaseComponentFormView {
                    let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
                    componentFormView.paddingLeft = newValue
                }
            }
            thePaddingLeft = newValue
        }
        get {
            return thePaddingLeft
        }
    }
    
    // space between the label and the component
    @IBInspectable var gap: CGFloat {
        set {
            for formItem: VGBaseFormItem in theFormItems.values {
                let componentForm: VGFormProtocol = formItem.componentForm
                if componentForm is VGBaseComponentFormView {
                    let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
                    componentFormView.gap = newValue
                }
            }
            theGap = newValue
        }
        get {
            return theGap
        }
    }
    
    var defaultButton: NSButton {
        set {
            self.theDefaultButton = defaultButton
            //self._defaultButton?.targe
        }
        get {
            return self.theDefaultButton!
        }
    }
    
    func check() {
        self.isValid = true
        var theData: [String: Any] = [String : Any]()
        
        var errorFormItems: [VGBaseFormItem] = [VGBaseFormItem]()
        
        for formItem: VGBaseFormItem in theFormItems.values {
            let componentForm: VGFormProtocol = formItem.componentForm
            
            if componentForm is VGBaseComponentFormView {
                let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
                print("V&G_FW___check : ", self, componentFormView.currentState)
                if componentFormView.currentState == .invalidate {
                    print("V&G_FW___check : ", self, componentFormView.currentState)
                    componentFormView.validate()
                }
            }
            
            componentForm.check()
            
            var isCheckBox: Bool = false
            if componentForm is NSButton {
                let checkBox: NSButton = componentForm as! NSButton
                isCheckBox = checkBox.allowsMixedState
            }
            
            print("V&G_FW___check : ", self, componentForm, "formItem", formItem)
            
            let isRequired: Bool = formItem.isRequired
            let isValid: Bool = componentForm.isValid!
            let theValue: Any? = componentForm.value
            
            if ((isRequired && !isValid) || (isRequired && theValue == nil) || (isCheckBox && theValue == nil && isRequired)) {
                self.isValid = false
                componentForm.invalidate()
                errorFormItems.append(formItem)
            } else {
                theData[formItem.code] = theValue
            }
            
        }
        //print("V&G_FW___check : ", self, self.isValid!)
        if self.isValid! {
            print("V&G_FW___check : ", self, value)
            value = theData
            delegate.validatedForm(form: self, value: theData)
            if isAutoClear {
                clear()
            }
        } else {
            delegate.invalidatedForm(form: self, errorFormItems: errorFormItems)
            for formItem: VGBaseFormItem in theFormItems.values {
                print("V&G_FW___check :: error with : ", self, formItem.code)
            }
        }
    }
    
    func validate() {
        print("V&G_FW___valid : ", self)
        for formItem: VGBaseFormItem in theFormItems.values {
            formItem.componentForm.validate()
        }
    }
    
    func invalidate() {
        print("V&G_FW___invalid : ", self)
        for formItem: VGBaseFormItem in theFormItems.values {
            formItem.componentForm.invalidate()
        }
    }
    
    func clear() {
        print("V&G_FW___clear : ", self)
        for formItem: VGBaseFormItem in theFormItems.values {
            formItem.componentForm.clear()
        }
    }
    
    func addItem(componentForm: VGFormProtocol, code:String, isRequired: Bool = true) {
        let formItem: VGBaseFormItem = VGBaseFormItem(componentForm: componentForm, code: code, isRequired: isRequired)
        theFormItems[code] = formItem
        formItem.validationMode = theValidationMode
        
        if componentForm is VGBaseComponentFormView {
            let componentFormView: VGBaseComponentFormView = componentForm as! VGBaseComponentFormView
            componentFormView.paddingRight = thePaddingRight
            componentFormView.paddingLeft = thePaddingLeft
            componentFormView.gap = theGap
        }
    }
    
    func getFormItem(formItemCode: String) -> VGBaseFormItem? {
        return theFormItems[formItemCode]
    }
    
    func getItem(formItemCode: String) -> VGFormProtocol {
        let theFormItem: VGBaseFormItem = theFormItems[formItemCode]!
        return theFormItem.componentForm
    }
    
    func getItems() -> [VGFormProtocol] {
        var items = [VGFormProtocol]()
        for formItem in theFormItems.values {
            items.append(formItem.componentForm)
        }
        return items
    }
    
    var validationMode: VGFormValidationMode {
        set {
            theValidationMode = newValue
            for formItem: VGBaseFormItem in theFormItems.values {
                formItem.validationMode = theValidationMode
            }
        }
        get {
            return theValidationMode
        }
    }
    
}

@IBDesignable class VGBaseComponentFormView:VGBaseNSView, VGFormProtocol {
    
    var value: Any?
    var isValid: Bool?
    
    internal var theLabel: NSTextField?
    internal var theCurrentState: VGComponentFormState?
    internal var theValidationMode: VGFormValidationMode?
    internal var thePaddingRightConstraint: NSLayoutConstraint?
    internal var thePaddingLeftConstraint: NSLayoutConstraint?
    internal var theGap: CGFloat = 5.0
    internal var theGapConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    internal var theBox: NSBox?
    
    internal func initBounds(isVisible: Bool = true) {
        wantsLayer = true
        layer?.masksToBounds = false
        
        theBox!.wantsLayer = true
        theBox!.layer?.masksToBounds = false
        
        theBox!.contentView!.wantsLayer = true
        theBox!.contentView!.layer?.masksToBounds = false
    }
    
    var paddingRight: CGFloat {
        set {
            thePaddingRightConstraint?.constant = newValue
        }
        get {
            return (thePaddingRightConstraint?.constant)!
        }
    }
    
    var paddingLeft: CGFloat {
        set {
            thePaddingLeftConstraint?.constant = newValue
        }
        get {
            return (thePaddingLeftConstraint?.constant)!
        }
    }
    
    var gap: CGFloat {
        set {
            for constraint in theGapConstraints {
                constraint.constant = newValue
            }
            //theGapConstraint?.constant = newValue
        }
        get {
            return theGap
        }
    }
    
    var textLabel: String {
        set {
            self.theLabel?.stringValue = newValue
        }
        get {
            return (theLabel?.stringValue)!
        }
    }
    
    var validationMode: VGFormValidationMode? {
        set {
            self.theValidationMode = newValue
        }
        get {
            if let theValidationModeTest = theValidationMode {
                return self.theValidationMode!
            }
            return nil
        }
    }
    
    var currentState: VGComponentFormState? {
        get {
            if let theCurrentStateTest = theCurrentState {
                return self.theCurrentState!
            }
            return nil
        }
    }
    
    func check() {
        print("V&G_FW___check : ", self.value)
        
        self.isValid = (self.value == nil) ? false : true;
    }
    
    func validate() {
        print("V&G_FW___validate : ", self)
        
        theBox?.title = ""
        theBox?.borderType = .noBorder
        theBox?.borderColor = .clear
        
        theCurrentState = VGComponentFormState.validate
    }
    
    func invalidate() {
        print("V&G_FW___invalidate : ", self)
        
        theBox?.borderType = .lineBorder
        theBox?.borderColor = .red
        theBox?.borderWidth = 1
        theBox?.cornerRadius = 1
        
        theCurrentState = VGComponentFormState.invalidate
    }
    
    func clear() {
        print("V&G_FW___clear : ", self)
        
        validate()
        value = nil
    }
    
}

@IBDesignable class VGBaseTextComponentFormView: VGBaseUIComponentWrapper, NSTextViewDelegate {
    
    internal var theTextComponent: NSTextField?
    //internal var hasChanged: Bool?
    
    override var value: Any? {
        get {
            print("V&G_Project___value : ", self.theTextComponent)
            if (self.theTextComponent?.stringValue.count)! > 0 {
                return self.theTextComponent?.stringValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                self.theTextComponent?.stringValue = newValue as! String
            } else {
                self.theTextComponent?.stringValue = ""
            }
        }
    }
    
    override var UIComponent: NSControl {
        get {
            return theTextComponent!
        }
    }
    
    /*func textDidChange(_ notification: Notification) {
        let textView: NSTextView = notification.object as! NSTextView
        //let textField: NSTextField = textView.text
        value = textView.string
    }*/
    
}

@IBDesignable class VGBaseUIComponentWrapper: VGBaseComponentFormView {
    
    internal var theUIComponent: NSControl?
    
    var UIComponent: NSControl {
        get {
            return self.theUIComponent!
        }
    }
    
}

enum VGFormValidationMode: Int {
    case check = 0
    case focusOut = 1
    case live = 2
}

enum VGComponentFormState: Int {
    case invalidate = 0
    case validate = 1
}

class VGBaseFormItem {
    
    private var _theComponentForm: VGFormProtocol
    private var _theCode: String
    private var _theIsRequired: Bool
   // private var _theValidationMode: VGFormValidationMode?
    
    init(componentForm: VGFormProtocol, code: String, isRequired: Bool = true) {
        self._theComponentForm = componentForm
        self._theCode = code
        self._theIsRequired = isRequired
    }
    
    var componentForm: VGFormProtocol {
        get {
            return _theComponentForm
        }
    }
    
    var code: String {
        set(newValue) {
            _theCode = newValue
        }
        get {
            return _theCode
        }
    }
    
    var isRequired: Bool {
        set(newValue) {
            _theIsRequired = newValue
        }
        get {
            return _theIsRequired
        }
    }
    
    var validationMode: VGFormValidationMode? {
        set {
            if _theComponentForm is VGBaseComponentFormView {
                let theComponentForm: VGBaseComponentFormView = _theComponentForm as! VGBaseComponentFormView
                theComponentForm.theValidationMode = validationMode
            }
        }
        get {
            if _theComponentForm is VGBaseComponentFormView {
                let theComponentForm: VGBaseComponentFormView = _theComponentForm as! VGBaseComponentFormView
                return theComponentForm.validationMode
            }
            return nil
        }
    }
    
}

protocol VGBaseGroupFromProtocol {
    func addItem(item: VGBaseComponentFormView)
    var items: [VGBaseComponentFormView]? {get}
}

class VGBaseGroupFormView: VGBaseComponentFormView, VGBaseGroupFromProtocol {
    
    internal var theItems: [VGBaseComponentFormView] = [VGBaseComponentFormView]()
    
    func addItem(item: VGBaseComponentFormView) {
        theItems.append(item)
    }
    
    var items: [VGBaseComponentFormView]? {
        get {
            return theItems
        }
    }
    
    override var paddingRight: CGFloat {
        set {
            for item in theItems {
                item.paddingRight = newValue
            }
        }
        get {
            return super.paddingRight
        }
    }
    
    override var paddingLeft: CGFloat {
        set {
            for item in theItems {
                item.paddingLeft = newValue
            }
        }
        get {
            return super.paddingLeft
        }
    }
    
    override var gap: CGFloat {
        set {
            for item in theItems {
                item.gap = newValue
            }
        }
        get {
            return super.gap
        }
    }
    
    override func validate() {
        super.validate()
        
        for item in theItems {
            item.validate()
        }
    }
    
    override func invalidate() {
        super.invalidate()
        
        for item in theItems {
            item.invalidate()
        }
    }
    
    override var validationMode: VGFormValidationMode? {
        get {
            return theValidationMode
        }
        set(newValue) {
            for item in theItems {
                item.validationMode = newValue
            }
        }
    }
    
    override func clear() {
        for item in theItems {
            item.clear()
        }
        super.clear()
    }
    
    override func check() {
        super.check()
        
        value = nil
        self.isValid = true
    }
    
}

class GroupFormView: VGBaseGroupFormView {
    
}

class TextComponentGroupFromView: GroupFormView {
    
    override func check() {
        super.check()
        
        for item in theItems {
            let textComponentFormView: VGBaseTextComponentFormView = item as! VGBaseTextComponentFormView
            if value != nil {
                let theValue: String = value as! String
                let theItemValue: String? = textComponentFormView.value == nil ? nil : textComponentFormView.value as! String
                if (theValue != theItemValue) {
                    isValid = false
                    return
                }
            }
            value = textComponentFormView.value
        }
    }
    
}

struct VGBaseDataFormStruct {
    
    let label: String
    let data: Any?
    
    init(label: String, data: Any?) {
        self.label = label
        self.data = data
    }
    
}
