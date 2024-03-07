//
//  Event.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct Event: FirebaseModel, Codable, Hashable {
    var id: String?
    var clientEventId: String?
    let name: String?
    let image: String?
    let description: String?
    let icon: String?
    var pendingDays: Int?
    let index: Int?
    let text_position: String?
    let video: String?

    init(id: String, clientEventId: String, name: String, image: String, description: String, icon: String, pendingDays: Int? = nil, index: Int, text_position: String, video: String) {
        self.id = id
        self.clientEventId = clientEventId
        self.name = name
        self.image = image
        self.description = description
        self.icon = icon
        self.pendingDays = pendingDays
        self.index = index
        self.text_position = text_position
        self.video = video
    }

    init(id: String) {
        self.id = id
        self.clientEventId = ""
        self.name = id.isEmpty ? "Editar Servicio" : "Nuevo Servicio"
        self.image = ""
        self.description = ""
        self.icon = ""
        self.pendingDays = 0
        self.index = 0
        self.text_position = ""
        self.video = ""
    }
}
