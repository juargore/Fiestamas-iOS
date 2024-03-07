//
//  Attribute.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct Attribute: FirebaseModel, Codable, Hashable, Identifiable {
    var id: String?
    let name: String
    let icon: String

    init() {
        self.id = ""
        self.name = ""
        self.icon = ""
    }
}
