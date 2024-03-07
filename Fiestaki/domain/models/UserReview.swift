//
//  UserReview.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct UserReview:  Codable, Hashable {
    var id: String
    let name: String
    let photo: String
    let message: String
}
