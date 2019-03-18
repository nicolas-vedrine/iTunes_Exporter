//
//  VGBaseForm.swift
//  iTunes Exporter
//
//  Created by Developer on 21/02/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

struct VGBaseFormObject {
    
    let label: String
    let data: Any?
    
    init(label: String, data: Any?) {
        self.label = label
        self.data = data
    }
    
}
