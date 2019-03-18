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
    
    init(fileManager: FileManager, srcPath: String, dstPath: String, ifFileAlreadyExistsType: IfFileAlreadyExistsType = IfFileAlreadyExistsType.overwrite) {
        self.fileManager = fileManager
        self.srcPath = srcPath
        self.dstPath = dstPath
        self.ifFileAlreadyExistsType = ifFileAlreadyExistsType
    }
    
    override func execute() {
        print("V&G_FW___execute : ", self, srcPath, dstPath)
        
        copyFile()
    }
    
    func copyFile() {
        if !isCancelled {
            /*let theFileURL: URL = URL(fileURLWithPath: srcPath)
             let theSourcePathStr: String = theFileURL.path*/
            //let theSourcePathURL: URL = URL(fileURLWithPath: srcPath)
            let theDestinationPathURL: URL = URL(fileURLWithPath: dstPath)
            let theSplittedDestinationPath: [String] = dstPath.components(separatedBy: "/")
            let theFileName: String = theSplittedDestinationPath[theSplittedDestinationPath.count - 1]
            let theDestinationFolderStr: String = String(dstPath.prefix(dstPath.count - theFileName.count))
            let theDestinationFolderURL: URL = URL(fileURLWithPath: theDestinationFolderStr)
            let isTheFileExists: Bool = theDestinationPathURL.isPathExists()
            if isTheFileExists {
                switch ifFileAlreadyExistsType {
                case .overwrite:
                    _overwrite(theFileManager: fileManager, srcPath: srcPath, dstPath: dstPath)
                case .overwriteOnlyIfMostRecent:
                    _overwriteOnlyIfMostRecent(theFileManager: fileManager, srcPath: srcPath, dstPath: dstPath)
                case .keepBoth:
                    _keepBoth(theFileManager: fileManager, srcPath: srcPath, dstPath: dstPath)
                case .ask:
                    print("V&G_FW___<#name#> : ", self)
                default:
                    _ignore()
                }
            } else {
                let isTheFolderExists: Bool = theDestinationFolderURL.isPathExists()
                if isTheFolderExists {
                    _copyFileAtPath(theFileManager: fileManager, srcPath: srcPath, dstPath: dstPath)
                } else {
                    _createDirectory(theFileManager: fileManager, atPath: theDestinationFolderStr)
                    _copyFileAtPath(theFileManager: fileManager, srcPath: srcPath, dstPath: dstPath)
                }
            }
        }
    }
    
    private func _copyFileAtPath(theFileManager: FileManager, srcPath: String, dstPath: String) {
        do {
            try theFileManager.copyItem(atPath: srcPath, toPath: dstPath)
        } catch let error {
            print("V&G_FW____copyFileAtPath : ", error.localizedDescription)
        }
    }
    
    private func _createDirectory(theFileManager: FileManager, atPath: String) {
        let theDestinationPathStr: String = atPath
        let theSplittedDestinationPath: [String] = theDestinationPathStr.components(separatedBy: "/")
        let theFileName: String = theSplittedDestinationPath[theSplittedDestinationPath.count - 1]
        let theDestinationFolderStr: String = String(theDestinationPathStr.prefix(theDestinationPathStr.count - theFileName.count))
        do {
            try theFileManager.createDirectory(atPath: theDestinationFolderStr, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("V&G_FW____createDirectory : ", error.localizedDescription)
        }
    }
    
    private func _overwrite(theFileManager: FileManager, srcPath: String, dstPath: String) {
        _replaceItemAtPath(theFileManager: theFileManager, srcPath: srcPath, dstPath: dstPath)
    }
    
    private func _overwriteOnlyIfMostRecent(theFileManager: FileManager, srcPath: String, dstPath: String) {
        let theSourcePathURL: URL = URL(fileURLWithPath: srcPath)
        let theDestinationPathURL: URL = URL(fileURLWithPath: dstPath)
        if theSourcePathURL.isMostRecenThan(url: theDestinationPathURL) {
            print("V&G_FW____overwriteOnlyIfMostRecent", "isMostRecenThan")
            _replaceItemAtPath(theFileManager: theFileManager, srcPath: srcPath, dstPath: dstPath)
        } else {
            _ignore()
        }
    }
    
    private func _keepBoth(theFileManager: FileManager, srcPath: String, dstPath: String, theFileNameIndex: Int = 1) {
        let theDestinationPathStr: String = dstPath
        let theDestinationPathURL: URL = URL(fileURLWithPath: theDestinationPathStr)
        let theFileName: String = theDestinationPathURL.getFileName()
        let theFileNameWithoutExtension: String = theDestinationPathURL.getFileNameWithoutExtension()
        let theFileNameExtension: String = theDestinationPathURL.getFileExtension()
        let theDestinationFolderStr: String = String(theDestinationPathStr.prefix(theDestinationPathStr.count - theFileName.count))
        let theIndex: Int = theFileNameIndex
        let theNewDestinationPathStr: String = theDestinationFolderStr + theFileNameWithoutExtension + " " + String(theIndex) + "." + theFileNameExtension
        do {
            print("V&G_FW____keepBoth : ", srcPath, theNewDestinationPathStr)
            try theFileManager.copyItem(atPath: srcPath, toPath: "/" + theNewDestinationPathStr)
        } catch let error {
            print("V&G_FW___keepBoth error : ", error.localizedDescription)
            _keepBoth(theFileManager: theFileManager, srcPath: srcPath, dstPath: dstPath, theFileNameIndex: theIndex + 1)
        }
    }
    
    private func _ignore() {
        print("V&G_FW____ignore : ", "do nothing")
    }
    
    private func _replaceItemAtPath(theFileManager: FileManager, srcPath: String, dstPath: String) {
        do {
            try theFileManager.removeItem(atPath: dstPath)
        } catch let error {
            print("V&G_FW____replaceItemAtPath : ", error.localizedDescription)
        }
        do {
            try theFileManager.copyItem(atPath: srcPath, toPath: dstPath)
        } catch let error {
            print("V&G_FW____replaceItemAtPath : ", error.localizedDescription)
        }
    }
    
    override func cancel() {
        // stop fileManager copy...
        
        super.cancel()
    }
    
}

enum IfFileAlreadyExistsType: Int {
    case overwrite = 0
    case overwriteOnlyIfMostRecent = 1
    case keepBoth = 2
    case ignore = 3
    case ask = 4
}
