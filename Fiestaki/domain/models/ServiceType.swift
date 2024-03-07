//
//  ServiceType.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ServiceType: FirebaseModel, Codable, Hashable {
    var id: String?
    let name: String
    let image: String
    let description: String?
    let icon: String
    let id_service_category: String

    init(id: String, name: String, image: String, description: String, icon: String, id_service_category: String) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.icon = icon
        self.id_service_category = id_service_category
    }

    init(id: String) {
        self.id = id
        self.name = ""
        self.image = ""
        self.description = ""
        self.icon = ""
        self.id_service_category = ""
    }
}

