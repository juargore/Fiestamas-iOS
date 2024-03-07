//
//  MessageResponse.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct NotificationDb: FirebaseModel, Codable, Hashable {
    var id: String?
    let content: String
    let id_client_event: String
    let id_receiver: String
    let id_sender: String
    let id_service: String
    let id_service_event: String
    let name_receiver: String
    let name_sender: String
    let photo: String
    let photo_receiver: String?
    let photo_sender: String?
    let read: Bool
    let received: Bool
    let sent: Bool
    let timestamp: String?
    let is_approved: Bool?
    let type: String

    init(id: String = "", content: String, id_client_event: String, id_receiver: String, id_sender: String, id_service: String, id_service_event: String, name_receiver: String, name_sender: String, photo: String, photo_receiver: String?, photo_sender: String?, read: Bool, received: Bool, sent: Bool, timestamp: String?, is_approved: Bool? = nil, type: String) {
        self.id = id
        self.content = content
        self.id_client_event = id_client_event
        self.id_receiver = id_receiver
        self.id_sender = id_sender
        self.id_service = id_service
        self.id_service_event = id_service_event
        self.name_receiver = name_receiver
        self.name_sender = name_sender
        self.photo = photo
        self.photo_receiver = photo_receiver
        self.photo_sender = photo_sender
        self.read = read
        self.received = received
        self.sent = sent
        self.timestamp = timestamp
        self.is_approved = is_approved
        self.type = type
    }

    init() {
        self.init(id: "", content: "", id_client_event: "", id_receiver: "", id_sender: "", id_service: "", id_service_event: "", name_receiver: "", name_sender: "", photo: "", photo_receiver: nil, photo_sender: nil, read: false, received: false, sent: false, timestamp: nil, is_approved: nil, type: "")
    }
}
