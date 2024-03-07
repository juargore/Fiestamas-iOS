//
//  UriFile.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct UriFile: Codable, Hashable {
    let uri: URL
    let fileName: String
    let url: String?

    init(uri: URL, fileName: String, url: String? = nil) {
        self.uri = uri
        self.fileName = fileName
        self.url = url
    }
}
