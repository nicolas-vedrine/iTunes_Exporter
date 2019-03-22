//
//  DataSources.swift
//  iTunes Exporter
//
//  Created by Developer on 20/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class DataSources {
    
    static func getFileNameDataSource() -> [VGBaseDataFormStruct] {
        var theDataSource: [VGBaseDataFormStruct] = [VGBaseDataFormStruct]()
        
        let fileName = VGBaseDataFormStruct(label: "<nom de fichier>", data: FileNameType.fileName)
        theDataSource.append(fileName)
        
        let artistSepAlbumSlashFileName = VGBaseDataFormStruct(label: "<artist> - <album> / <file name>", data: FileNameType.artistSepAlbumSlashFileName)
        theDataSource.append(artistSepAlbumSlashFileName)
        
        let artistSlashAlbumSlashFileName = VGBaseDataFormStruct(label: "<artist> / <album> / <file name>", data: FileNameType.artistSlashAlbumSlashFileName)
        theDataSource.append(artistSlashAlbumSlashFileName)
        
        let albumSlashFileName = VGBaseDataFormStruct(label: "<album> / <file name>", data: FileNameType.albumSlashFileName)
        theDataSource.append(albumSlashFileName)
        
        let artistSlashFileName = VGBaseDataFormStruct(label: "<artist> / <file name>", data: FileNameType.artistSlashFileName)
        theDataSource.append(artistSlashFileName)
        
        return theDataSource
    }
    
    static func getIfAlreadyExistsDataSource() -> [VGBaseDataFormStruct] {
        var theDataSource = [VGBaseDataFormStruct]()
        
        let overwrite = VGBaseDataFormStruct(label: "overwrite", data: IfFileAlreadyExistsType.overwrite)
        theDataSource.append(overwrite)
        
        let overwriteOnlyIfMostRecent = VGBaseDataFormStruct(label: "overwrite if most recent", data: IfFileAlreadyExistsType.overwriteOnlyIfMostRecent)
        theDataSource.append(overwriteOnlyIfMostRecent)
        
        let ignore = VGBaseDataFormStruct(label: "ignore", data: IfFileAlreadyExistsType.ignore)
        theDataSource.append(ignore)
        
        let keepBoth = VGBaseDataFormStruct(label: "keep both", data: IfFileAlreadyExistsType.keepBoth)
        theDataSource.append(keepBoth)
        
        let ask = VGBaseDataFormStruct(label: "ask...", data: IfFileAlreadyExistsType.ask)
        theDataSource.append(ask)
        
        return theDataSource
    }

}
