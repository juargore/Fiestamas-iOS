//
//  CreateEventRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct CreateEventRequest: Codable, Hashable {
    //let id: String?
    let name: String
    let id_client: String
    let id_event_type: String
    let date: String
    let location: String
    let lat: String
    let lng: String
    let attendees: String
}

struct CreateEventResponse: Codable, Hashable {
    let id: String
    let name: String
}
