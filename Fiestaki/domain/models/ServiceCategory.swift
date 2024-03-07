//
//  ServiceCategory.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ServiceCategory: FirebaseModel, Codable, Hashable, Identifiable {
    var id: String?
    let name: String?
    let image: String?
    let description: String?
    let icon: String?
    let events_types: [String]?

    init(id: String, name: String, image: String, description: String, icon: String, events_types: [String]) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.icon = icon
        self.events_types = events_types
    }

    init(id: String) {
        self.id = id
        self.name = ""
        self.image = ""
        self.description = ""
        self.icon = ""
        self.events_types = []
    }
}

