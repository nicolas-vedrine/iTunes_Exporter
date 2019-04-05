//
//  DataSources.swift
//  iTunes Exporter
//
//  Created by Developer on 20/03/2019.
//  Copyright © 2019 Nicolas VEDRINE. All rights reserved.
//

import Foundation

class DataSources {
    
    static func getFileNameDataSource() -> [VGBaseDataForm] {
        var theDataSource: [VGBaseDataForm] = [VGBaseDataForm]()
        
        let fileName = VGBaseDataForm(label: "<nom de fichier>", data: iTunesExportFileNameType.fileName)
        theDataSource.append(fileName)
        
        let artistSepAlbumSlashFileName = VGBaseDataForm(label: "<artist> - <album> / <file name>", data: iTunesExportFileNameType.artistSepAlbumSlashFileName)
        theDataSource.append(artistSepAlbumSlashFileName)
        
        let artistSlashAlbumSlashFileName = VGBaseDataForm(label: "<artist> / <album> / <file name>", data: iTunesExportFileNameType.artistSlashAlbumSlashFileName)
        theDataSource.append(artistSlashAlbumSlashFileName)
        
        let albumSlashFileName = VGBaseDataForm(label: "<album> / <file name>", data: iTunesExportFileNameType.albumSlashFileName)
        theDataSource.append(albumSlashFileName)
        
        let artistSlashFileName = VGBaseDataForm(label: "<artist> / <file name>", data: iTunesExportFileNameType.artistSlashFileName)
        theDataSource.append(artistSlashFileName)
        
        return theDataSource
    }
    
    static func getIfAlreadyExistsDataSource() -> [VGBaseDataForm] {
        var theDataSource = [VGBaseDataForm]()
        
        let overwrite = VGBaseDataForm(label: "overwrite", data: IfFileAlreadyExistsType.overwrite)
        theDataSource.append(overwrite)
        
        let overwriteOnlyIfMostRecent = VGBaseDataForm(label: "overwrite if most recent", data: IfFileAlreadyExistsType.overwriteOnlyIfMostRecent)
        theDataSource.append(overwriteOnlyIfMostRecent)
        
        let ignore = VGBaseDataForm(label: "ignore", data: IfFileAlreadyExistsType.ignore)
        theDataSource.append(ignore)
        
        let keepBoth = VGBaseDataForm(label: "keep both", data: IfFileAlreadyExistsType.keepBoth)
        theDataSource.append(keepBoth)
        
        /*let ask = VGBaseDataForm(label: "ask...", data: IfFileAlreadyExistsType.ask)
        theDataSource.append(ask)*/
        
        return theDataSource
    }

}
