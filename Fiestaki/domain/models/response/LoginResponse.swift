//
//  LoginResponse.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/10/23.
//

import Foundation

struct LoginResponse: Codable, Hashable {
    let success: Bool
    let uid: String
}
