//
//  GoogleServicesUseCase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

class GoogleServicesUseCase {
    
    private let googleRepository = GoogleServicesRepositoryImpl()
    
    func autocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never> {
        return googleRepository.autocompletePublisher(query: query)
    }
    
    func cityAutocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never> {
        return googleRepository.cityAutocompletePublisher(query: query)
    }
    
    func getAddressByPlaceIdPublisher(placeId: String) -> AnyPublisher<Address, Never> {
        return googleRepository.getAddressByPlaceIdPublisher(placeId: placeId)
    }
}
