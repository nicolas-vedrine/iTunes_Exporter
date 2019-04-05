//
//  AsyncOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class VGOperation: Operation {
    
    @objc private enum State: Int {
        case ready
        case executing
        case finished
        //case cancelled
    }
    
    private var _state = State.ready
    private let _stateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".op.state", attributes: .concurrent)
    
    var operationQueue: OperationQueue?
    var index: Int?
    
    @objc private dynamic var state: State {
        get { return _stateQueue.sync { _state } }
        set { _stateQueue.sync(flags: .barrier) { _state = newValue } }
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    var _isCancelled: Bool = false
     
    override var isCancelled: Bool {
        set {
            willChangeValue(forKey: Operation.CANCELLED)
            _isCancelled = newValue
            didChangeValue(forKey: Operation.CANCELLED)
        }
        get {
            return _isCancelled
        }
    }
    
    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if [READY, FINISHED, EXECUTING].contains(key) {
            return [#keyPath(state)]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    override func main() {
        fatalError("Implement in sublcass to perform task")
    }
    
    override func start() {
        if isCancelled {
            finish()
            return
        }
        self.state = .executing
        main()
    }
    
    override func cancel() {
        print("V&G_FW___cancel : ", self, isExecuting)
        isCancelled = true
        //super.cancel()
    }
    
    internal final func finish() {
        if isExecuting {
            state = .finished
        }
    }
}

class AsyncOperation: VGOperation {
    
    override var isAsynchronous: Bool {
        return false
    }
    
}

extension Operation {
    
    public static let READY: String = "isReady"
    public static let FINISHED: String = "isFinished"
    public static let EXECUTING: String = "isExecuting"
    public static let CANCELLED: String = "isCancelled"
    //public static let ASKING: String = "isAsking"
    
}
