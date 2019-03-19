//
//  AsyncOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    var operationQueue: OperationQueue?
    var index: Int?
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var _isFinished: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: Operation.FINISHED)
            _isFinished = newValue
            didChangeValue(forKey: Operation.FINISHED)
            print("V&G_FW___isFinished : ", self, isFinished)
        }
        
        get {
            return _isFinished
        }
    }
    
    var _isExecuting: Bool = false
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: Operation.EXECUTING)
            _isExecuting = newValue
            didChangeValue(forKey: Operation.EXECUTING)
        }
        
        get {
            return _isExecuting
        }
    }
    
    /*var _isCancelled: Bool = false
    
    override var isCancelled: Bool {
        set {
            willChangeValue(forKey: Operation.CANCELLED)
            _isCancelled = newValue
            didChangeValue(forKey: Operation.CANCELLED)
        }
        
        get {
            return _isCancelled
        }
    }*/
    
    func execute() {
    }
    
    override func start() {
        isExecuting = true
        execute()
        isExecuting = false
        isFinished = true
    }
    
}

extension Operation {
    
    public static let FINISHED: String = "isFinished"
    public static let EXECUTING: String = "isExecuting"
    public static let CANCELLED: String = "isCancelled"
    //public static let ASKING: String = "isAsking"
    
}
