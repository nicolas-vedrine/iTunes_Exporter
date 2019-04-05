//
//  CopyFilesOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class VGOperationQueue: OperationQueue {
    
    var count: Int = 0
    var isCancelled: Bool = false
    
    override func addOperation(_ op: Operation) {
        super.addOperation(op)
        
        count = operations.count
    }
    
    override func cancelAllOperations() {
        super.cancelAllOperations()
        
        isCancelled = true
    }
    
}

class FileOperationQueue: VGOperationQueue {
    
}
