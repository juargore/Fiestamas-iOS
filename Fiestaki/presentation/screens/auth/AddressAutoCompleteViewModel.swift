//
//  AddressAutoCompleteViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/20/23.
//

import Foundation
import Combine
import SwiftUI

final class AddressAutoCompleteViewModel: ObservableObject {
    
    private let googleUseCase = GoogleServicesUseCase()
    private var disposables = Set<AnyCancellable>()
    
    @Published var placesList: [PlaceAutocomplete] = []
    @Published var address: Address? = nil
    
    func findCityByQuery(query: String) {
        googleUseCase
            .cityAutocompletePublisher(query: query)
            .sink { _ in } receiveValue: { list in
                self.placesList = list
            }.store(in: &disposables)
    }
    
    func findPlaceByQuery(query: String) {
        googleUseCase
            .autocompletePublisher(query: query)
            .sink { _ in } receiveValue: { list in
                self.placesList = list
            }.store(in: &disposables)
    }
    
    func getAddressByPlaceId(placeId: String, onFinished: @escaping (Address) -> Void) {
        googleUseCase
            .getAddressByPlaceIdPublisher(placeId: placeId)
            .sink { _ in } receiveValue: { address in
                self.address = address
                onFinished(address)
            }.store(in: &disposables)
    }
    
    func resetAddress() {
        placesList = []
        address = nil
    }
}
