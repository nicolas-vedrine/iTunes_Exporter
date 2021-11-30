//
//  Locale.swift
//  iTunes Exporter
//
//  Created by Developer on 30/11/2021.
//  Copyright © 2021 Nicolas VEDRINE. All rights reserved.
//

import Foundation

extension Locale {
    
    static public func getLocale() -> String {
        var localeString: String?
        let languageCode = NSLocale.current.languageCode
        if languageCode != LanguageCode.fr.rawValue && languageCode != LanguageCode.en.rawValue && languageCode != LanguageCode.es.rawValue {
            localeString = LanguageCode.fr.rawValue
        } else {
            return Locale.current.languageCode!
        }
        return localeString!
    }
    
}

enum LanguageCode: String {
    case fr = "fr"
    case en = "en"
    case es = "es"
    case de = "de"
    case ja = "ja"
    case ca = "ca"
}
