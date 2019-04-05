//
//  CopyOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class FileOperation: VGOperation {
    
    let fileManager: FileManager
    let srcPath: String
    let dstPath: String
    var ifFileAlreadyExistsType: IfFileAlreadyExistsType
    
    internal var theError: Error?
    
    var error: Error {
        get {
            return theError!
        }
    }
    
    init(fileManager: FileManager, srcPath: String, dstPath: String, ifFileAlreadyExistsType: IfFileAlreadyExistsType = IfFileAlreadyExistsType.overwrite) {
        self.fileManager = fileManager
        self.srcPath = srcPath
        self.dstPath = dstPath
        self.ifFileAlreadyExistsType = ifFileAlreadyExistsType
        
        super.init()
        
        self.fileManager.delegate = self
    }
    
    override func main() {
        print("V&G_FW___main : ", self, srcPath, dstPath, isCancelled)
        
        if !isCancelled {
            let theDestinationPathURL: URL = URL(fileURLWithPath: dstPath)
            let theSplittedDestinationPath: [String] = dstPath.components(separatedBy: "/")
            let theFileName: String = theSplittedDestinationPath[theSplittedDestinationPath.count - 1]
            let theDestinationFolderStr: String = String(dstPath.prefix(dstPath.count - theFileName.count))
            let theDestinationFolderURL: URL = URL(fileURLWithPath: theDestinationFolderStr)
            let isTheFileExists: Bool = theDestinationPathURL.isPathExists()
            if isTheFileExists {
                switch ifFileAlreadyExistsType {
                case .overwrite:
                    _overwrite()
                case .overwriteOnlyIfMostRecent:
                    _overwriteOnlyIfMostRecent()
                case .keepBoth:
                    _keepBoth()
                default:
                    _ignore()
                }
            } else {
                let isTheFolderExists: Bool = theDestinationFolderURL.isPathExists()
                if isTheFolderExists {
                    _copyItem(toPath: dstPath)
                } else {
                    _createDirectory(atPath: theDestinationFolderStr)
                    _copyItem(toPath: dstPath)
                }
            }
        }
    }
    
    private func _copyItem(toPath: String) {
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: toPath)
            finish()
        } catch let error {
            print("V&G_FW____copyFileAtPath : ", error.localizedDescription)
        }
    }
    
    private func _createDirectory(atPath: String) {
        let theDestinationPathStr: String = atPath
        let theSplittedDestinationPath: [String] = theDestinationPathStr.components(separatedBy: "/")
        let theFileName: String = theSplittedDestinationPath[theSplittedDestinationPath.count - 1]
        let theDestinationFolderStr: String = String(theDestinationPathStr.prefix(theDestinationPathStr.count - theFileName.count))
        do {
            try fileManager.createDirectory(atPath: theDestinationFolderStr, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("V&G_FW____createDirectory : ", error.localizedDescription)
            finish()
        }
    }
    
    private func _overwrite() {
        _replaceItem()
    }
    
    private func _overwriteOnlyIfMostRecent() {
        let theSourcePathURL: URL = URL(fileURLWithPath: srcPath)
        let theDestinationPathURL: URL = URL(fileURLWithPath: dstPath)
        if theSourcePathURL.isMostRecenThan(url: theDestinationPathURL) {
            print("V&G_FW____overwriteOnlyIfMostRecent", "isMostRecenThan")
            _replaceItem()
        } else {
            _ignore()
        }
    }
    
    private func _keepBoth(theFileNameIndex: Int = 1) {
        let theDestinationPathStr: String = dstPath
        let theDestinationPathURL: URL = URL(fileURLWithPath: theDestinationPathStr)
        let theFileName: String = theDestinationPathURL.getName()!
        let theFileNameWithoutExtension: String = theDestinationPathURL.getFileNameWithoutExtension()
        let theFileNameExtension: String = theDestinationPathURL.getFileExtension()
        let theDestinationFolderStr: String = String(theDestinationPathStr.prefix(theDestinationPathStr.count - theFileName.count))
        let theNewDestinationPathStr: String = theDestinationFolderStr + theFileNameWithoutExtension + " (" + String(theFileNameIndex) + ")." + theFileNameExtension
        let theNewDestinationPathUrl: URL = URL(fileURLWithPath: theNewDestinationPathStr)
        if theNewDestinationPathUrl.isPathExists() {
            _keepBoth(theFileNameIndex: theFileNameIndex + 1)
        } else {
            _copyItem(toPath: theNewDestinationPathStr)
        }
        /*do {
            print("V&G_FW____keepBoth : ", srcPath, theNewDestinationPathStr)
            try fileManager.copyItem(atPath: srcPath, toPath: "/" + theNewDestinationPathStr)
            finish()
        } catch let error {
            print("V&G_FW___keepBoth error : ", error.localizedDescription)
            _keepBoth(theFileNameIndex: theIndex + 1)
        }*/
    }
    
    private func _ignore() {
        print("V&G_FW____ignore : ", "do nothing")
        finish()
    }
    
    private func _replaceItem() {
        do {
            try fileManager.removeItem(atPath: dstPath)
        } catch let error {
            print("V&G_FW____replaceItemAtPath : ", error.localizedDescription)
        }
        _copyItem(toPath: dstPath)
    }
    
    override func cancel() {
        // TODO : stop fileManager copy...
        
        super.cancel()
    }
    
}

extension FileOperation: FileManagerDelegate {
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        print("V&G_FW___shouldProceedAfterError : ", self, error)
        self.theError = error
        return true
    }
    
}

enum IfFileAlreadyExistsType: Int {
    case overwrite = 0
    case overwriteOnlyIfMostRecent = 1
    case keepBoth = 2
    case ignore = 3
    case ask = 4
}
