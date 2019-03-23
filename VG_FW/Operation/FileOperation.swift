//
//  CopyOperation.swift
//  TestFile
//
//  Created by Developer on 01/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class FileOperation: AsyncOperation {
    
    let fileManager: FileManager
    let srcPath: String
    let dstPath: String
    var ifFileAlreadyExistsType: IfFileAlreadyExistsType
    var error: Error?
    
    init(fileManager: FileManager, srcPath: String, dstPath: String, ifFileAlreadyExistsType: IfFileAlreadyExistsType = IfFileAlreadyExistsType.overwrite) {
        self.fileManager = fileManager
        self.srcPath = srcPath
        self.dstPath = dstPath
        self.ifFileAlreadyExistsType = ifFileAlreadyExistsType
        
        super.init()
        
        self.fileManager.delegate = self
    }
    
    /*override func start() {
        isExecuting = true
        execute()
        /*isExecuting = false
        isFinished = true*/
    }*/
    
    override func main() {
        print("V&G_FW___execute : ", self, srcPath, dstPath)
        
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
                case .ask:
                    print("V&G_FW___ask : ", self)
                default:
                    _ignore()
                }
            } else {
                let isTheFolderExists: Bool = theDestinationFolderURL.isPathExists()
                if isTheFolderExists {
                    _copyFile()
                } else {
                    _createDirectory(atPath: theDestinationFolderStr)
                    _copyFile()
                }
            }
        }
    }
    
    private func _copyFile() {
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: dstPath)
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
        let theIndex: Int = theFileNameIndex
        let theNewDestinationPathStr: String = theDestinationFolderStr + theFileNameWithoutExtension + " " + String(theIndex) + "." + theFileNameExtension
        do {
            print("V&G_FW____keepBoth : ", srcPath, theNewDestinationPathStr)
            try fileManager.copyItem(atPath: srcPath, toPath: "/" + theNewDestinationPathStr)
            finish()
        } catch let error {
            print("V&G_FW___keepBoth error : ", error.localizedDescription)
            _keepBoth(theFileNameIndex: theIndex + 1)
        }
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
        do {
            try fileManager.copyItem(atPath: srcPath, toPath: dstPath)
            finish()
        } catch let error {
            print("V&G_FW____replaceItemAtPath : ", error.localizedDescription)
        }
    }
    
    override func cancel() {
        // stop fileManager copy...
        
        super.cancel()
    }
    
}

extension FileOperation: FileManagerDelegate {
    
    func fileManager(_ fileManager: FileManager, shouldProceedAfterError error: Error, copyingItemAt srcURL: URL, to dstURL: URL) -> Bool {
        print("V&G_FW___shouldProceedAfterError : ", self, error)
        self.error = error
        return false
    }
    
}

enum IfFileAlreadyExistsType: Int {
    case overwrite = 0
    case overwriteOnlyIfMostRecent = 1
    case keepBoth = 2
    case ignore = 3
    case ask = 4
}
