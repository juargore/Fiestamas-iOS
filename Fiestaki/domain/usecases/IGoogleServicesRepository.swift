//
//  IGoogleServicesRepository.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

protocol IGoogleServicesRepository {
    
    func autocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never>
    
    func cityAutocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never>
    
    func getAddressByPlaceIdPublisher(placeId: String) -> AnyPublisher<Address, Never>
}
