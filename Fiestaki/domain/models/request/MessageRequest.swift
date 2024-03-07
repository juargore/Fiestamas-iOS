//
//  MessageRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct NewChatMessageRequest: Codable, Hashable {
    let content: String
    let id_sender: String
    let id_receiver: String
    let id_service_event: String
    let id_service: String
    let id_client_event: String
    let type: String
}

struct MarkChatMessagesAsReadRequest: Codable, Hashable {
    let id_messages: [String]
}
