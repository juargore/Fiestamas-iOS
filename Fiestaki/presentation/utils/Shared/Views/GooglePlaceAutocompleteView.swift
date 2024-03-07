//
//  GooglePlaceAutocompleteView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 30/05/23.
//

import SwiftUI
import GooglePlaces

struct GooglePlaceAutocompleteView: UIViewControllerRepresentable {
    
    @Binding var selectedPlace: GooglePlace

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate, ObservableObject {
        var parent: GooglePlaceAutocompleteView

        init(_ parent: GooglePlaceAutocompleteView) {
            self.parent = parent
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

            guard let placeComponents = place.addressComponents else { return }

            placeComponents.forEach { addressComponent in
                addressComponent.types.forEach { type in
                    switch type {
                    case "route":
                        parent.selectedPlace.streetName = addressComponent.name
                    case "street_number":
                        parent.selectedPlace.streetNumber = addressComponent.name
                    case "neighborhood":
                        parent.selectedPlace.neighborhood = addressComponent.name
                    case "sublocality_level_1":
                        parent.selectedPlace.colony = addressComponent.name
                    case "locality":
                        parent.selectedPlace.city = addressComponent.name
                    case "administrative_area_level_1":
                        parent.selectedPlace.state = addressComponent.name
                    case "country":
                        parent.selectedPlace.country = addressComponent.name
                    case "postal_code":
                        parent.selectedPlace.postalCode = addressComponent.name
                    default:
                        break
                    }
                }
            }

            parent.selectedPlace.streetName.append(" \(parent.selectedPlace.streetNumber)")
            parent.selectedPlace.location = place.coordinate
            
            viewController.dismiss(animated: true, completion: nil)
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Autocomplete error: \(error.localizedDescription)")
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            debugPrint("AQUI: Was cancelled")
            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<GooglePlaceAutocompleteView>) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        
        autocompleteController.view.translatesAutoresizingMaskIntoConstraints = false

        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: UIViewControllerRepresentableContext<GooglePlaceAutocompleteView>) {
    }
}
