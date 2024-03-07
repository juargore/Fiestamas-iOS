//
//  FirebaseModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

protocol FirebaseModel: Codable, Hashable {
    var id: String? { get set }
}
