//
//  AsyncOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    @objc private enum State: Int {
        case ready
        case executing
        case finished
    }
    
    private var _state = State.ready
    private let stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
    
    var operationQueue: OperationQueue?
    var index: Int?
    
    @objc private dynamic var state: State {
        get { return stateQueue.sync { _state } }
        set { stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    //private var _isFinished: Bool = false
    /*override var isFinished: Bool {
        /*set {
            willChangeValue(forKey: Operation.FINISHED)
            _isFinished = newValue
            didChangeValue(forKey: Operation.FINISHED)
            print("V&G_FW___isFinished : ", self, isFinished)
        }*/
        
        get {
            return state == .finished
        }
    }*/
    
    public override var isFinished: Bool {
        return state == .finished
    }
    
    /*private var _isExecuting: Bool = false
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: Operation.EXECUTING)
            _isExecuting = newValue
            didChangeValue(forKey: Operation.EXECUTING)
        }
        
        get {
            return _isExecuting
        }
    }*/
    
    public override var isExecuting: Bool {
        return state == .executing
    }
    
    open override var isReady: Bool {
        return super.isReady && state == .ready
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
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isReady",  "isFinished", "isExecuting"].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    override func main() {
        fatalError("Implement in sublcass to perform task")
    }
    
    /*override func start() {
        isExecuting = true
        execute()
        isExecuting = false
        isFinished = true
    }*/
    
    public override func start() {
        if isCancelled {
            finish()
            return
        }
        self.state = .executing
        main()
    }
    
    internal final func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
}

extension Operation {
    
    public static let FINISHED: String = "isFinished"
    public static let EXECUTING: String = "isExecuting"
    public static let CANCELLED: String = "isCancelled"
    //public static let ASKING: String = "isAsking"
    
}
