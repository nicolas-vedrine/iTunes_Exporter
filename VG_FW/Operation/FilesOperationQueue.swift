//
//  CopyFilesOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class CopyFilesOperationQueue: OperationQueue {
    
    var count: Int = 0
    
    /*override func execute() {
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    override func cancel() {
        super.cancel()
        
        for i in 0...operations.count - 1 {
            let theCopyFileOperation: CopyFileOperation = operations[i] as! CopyFileOperation
            if !theCopyFileOperation.isFinished {
                theCopyFileOperation.cancel()
            }
        }
    }*/
    
    override func addOperation(_ op: Operation) {
        super.addOperation(op)
        
        count = operations.count
    }
    
}
