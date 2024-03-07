//
//  SubService.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct SubService: FirebaseModel, Codable, Hashable {
    var id: String?
    let id_service_type: String
    let name: String
    let image: String
    let description: String?
    let icon: String

    init(id: String, id_service_type: String, name: String, image: String, description: String, icon: String) {
        self.id = id
        self.id_service_type = id_service_type
        self.name = name
        self.image = image
        self.description = description
        self.icon = icon
    }

    init(id: String) {
        self.id = id
        self.id_service_type = ""
        self.name = ""
        self.image = ""
        self.description = ""
        self.icon = ""
    }
}
