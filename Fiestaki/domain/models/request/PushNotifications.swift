//
//  PushNotifications.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/10/23.
//

import Foundation

struct SubscribeRequest: Codable, Hashable {
    let device_token: String
    let uid: String
}

struct UpdateRequest: Codable, Hashable {
    let device_token: String
    let prev_device_token: String
    let uid: String
}
