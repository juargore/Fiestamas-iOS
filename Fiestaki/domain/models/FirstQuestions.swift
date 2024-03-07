//
//  FirstQuestions.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct FirstQuestions: Codable, Hashable {
    let festejadosNames: String
    let date: String
    let numberOfGuests: String
    let city: String
    let location: Location?

    init(festejadosNames: String, date: String, numberOfGuests: String, city: String, location: Location?) {
        self.festejadosNames = festejadosNames
        self.date = date
        self.numberOfGuests = numberOfGuests
        self.city = city
        self.location = location
    }
}
