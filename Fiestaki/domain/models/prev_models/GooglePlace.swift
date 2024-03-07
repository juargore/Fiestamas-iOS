//
//  GooglePlace.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 30/05/23.
//

import Foundation
import CoreLocation

struct GooglePlace {
    var streetNumber: String
    var streetName: String
    var neighborhood: String
    var colony: String // sublocality_level_1
    var city: String
    var state: String //administrative_area_level_1
    var country: String
    var postalCode: String
    var location: CLLocationCoordinate2D
}
