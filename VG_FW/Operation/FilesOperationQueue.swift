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
    
    override func addOperation(_ op: Operation) {
        super.addOperation(op)
        
        count = operations.count
    }
    
}
