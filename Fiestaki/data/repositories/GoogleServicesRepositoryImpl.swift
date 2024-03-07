//
//  GoogleServicesRepositoryImpl.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/20/23.
//

import Foundation
import Combine
import GooglePlaces

class GoogleServicesRepositoryImpl: IGoogleServicesRepository {
    
    private var placesClient = GMSPlacesClient.shared()
    
    func autocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never> {
        return Future { promise in
            let token = GMSAutocompleteSessionToken.init()
            let filter = GMSAutocompleteFilter()
            filter.countries = ["MX"]
            filter.type = GMSPlacesAutocompleteTypeFilter.address
            
            var resultList = [PlaceAutocomplete]()
            
            self.placesClient.findAutocompletePredictions(fromQuery: query,
                filter: filter, sessionToken: token) { predictions, error in
                if error != nil {
                    promise(.success([PlaceAutocomplete]()))
                } else {
                    predictions?.forEach { prediction in
                        resultList.append(
                            PlaceAutocomplete(
                                placeId: prediction.placeID,
                                primaryText: prediction.attributedPrimaryText.string,
                                secondaryText: prediction.attributedSecondaryText?.string ?? "",
                                fullAddress: prediction.attributedFullText.string
                            )
                        )
                    }
                    promise(.success(resultList))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func cityAutocompletePublisher(query: String) -> AnyPublisher<[PlaceAutocomplete], Never> {
        return Future { promise in
            let token = GMSAutocompleteSessionToken.init()
            let filter = GMSAutocompleteFilter()
            filter.countries = ["MX"]
            filter.type = GMSPlacesAutocompleteTypeFilter.city
            
            var resultList = [PlaceAutocomplete]()
            
            self.placesClient.findAutocompletePredictions(fromQuery: query,
                filter: filter, sessionToken: token) { predictions, error in
                if error != nil {
                    promise(.success([PlaceAutocomplete]()))
                } else {
                    predictions?.forEach { prediction in
                        resultList.append(
                            PlaceAutocomplete(
                                placeId: prediction.placeID,
                                primaryText: prediction.attributedPrimaryText.string,
                                secondaryText: prediction.attributedSecondaryText?.string ?? "",
                                fullAddress: prediction.attributedFullText.string
                            )
                        )
                    }
                    promise(.success(resultList))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getAddressByPlaceIdPublisher(placeId: String) -> AnyPublisher<Address, Never> {
        return Future { promise in
            let token = GMSAutocompleteSessionToken.init()
            self.placesClient.fetchPlace(
                fromPlaceID: placeId,
                placeFields: GMSPlaceField.all,
                sessionToken: token
            ) { place, error in
                if error != nil {
                    promise(.success(Address()))
                } else {
                    if place != nil {
                        let address = self.convertPlaceToAddress(place: place!)
                        var copyAddress = address
                        let latLng = place?.coordinate
                        let location = Location(lat: String(latLng?.latitude ?? 0), lng: String(latLng?.longitude ?? 0))
                        copyAddress.location = location
                        promise(.success(copyAddress))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func convertPlaceToAddress(place: GMSPlace) -> Address {
        var streetNumber = ""
        var streetAddress = ""
        var zipCode = ""
        var city = ""
        var country = ""
        var state = ""
        
        place.addressComponents?.forEach { component in
            if component.types.contains("country") {
                country = component.name
            }
            if component.types.contains("street_number") {
                streetNumber = component.name
            }
            if component.types.contains("route") {
                streetAddress = component.name
            }
            if component.types.contains("locality") {
                city = component.name
            }
            if component.types.contains("administrative_area_level_1") {
                state = component.name
            }
            if component.types.contains("country") {
                country = component.name
            }
            if component.types.contains("postal_code") {
                zipCode = component.name
            }
        }
        
        return Address(
            city: city,
            country: country,
            line1: "\(streetNumber) \(streetAddress)",
            state: state,
            zipcode: zipCode
        )
    }
}
