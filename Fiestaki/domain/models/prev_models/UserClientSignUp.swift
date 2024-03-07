//
//  UserClientSignUp.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 19/05/23.
//

import Foundation

struct UserClientSignUp: Encodable {
    let role: String
    let name: String
    let last_name: String
    let phone_one: String
    let phone_two: String
    let email: String
    let password: String
}
