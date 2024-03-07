//
//  AddressAutoCompleteScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/20/23.
//

import SwiftUI

struct AddressAutoCompleteScreen: View {
    
    @ObservedObject var viewModel = AddressAutoCompleteViewModel()
    @State private var query = ""
    
    var searchType: AddressSearchType
    var onAddressSelected: ((Address?) -> Void)? = nil
    var onCitySelected: ((Address?, String) -> Void)? = nil
    
    var body: some View {
        ZStack {
            VStack {
                CustomTextField(placeholder: "Buscar", text: $query)
                    .frame(height: 50)
                    .padding(.horizontal, 22)
                    .onChange(of: query) { nQuery in
                        if nQuery.count > 2 {
                            switch searchType {
                            case .address:
                                viewModel.findPlaceByQuery(query: nQuery)
                            case .city:
                                viewModel.findCityByQuery(query: nQuery)
                            }
                        }
                    }
                
                LazyVStack {
                    ForEach(viewModel.placesList, id: \.self) { place in
                        CardGooglePlay(item: place) { item in
                            viewModel.getAddressByPlaceId(placeId: item.placeId) { address in
                                onAddressSelected?(address)
                                onCitySelected?(address, "\(place.primaryText), \(place.secondaryText)")
                                query = ""
                                viewModel.resetAddress()
                            }
                        }
                    }
                }
                
                VStack {
                    Spacer()
                    Text("Cancelar")
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .onTapGesture {
                            onAddressSelected?(nil)
                            onCitySelected?(nil, "")
                            viewModel.resetAddress()
                        }
                    Image("img_powered_by_google")
                        .resizable()
                        .frame(width: 120, height: 15)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct CardGooglePlay: View {
    
    var item: PlaceAutocomplete
    var onItemClick: (PlaceAutocomplete) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: HorizontalAlignment.leading) {
                Text(item.primaryText)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(item.secondaryText)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 22)
            .onTapGesture {
                onItemClick(item)
            }
            Spacer()
        }
    }
}

struct AddressAutoCompleteScreen_Previews: PreviewProvider {
    static var previews: some View {
        CardGooglePlay(item: PlaceAutocomplete(
            placeId: "123",
            primaryText: "1100 Acueducto",
            secondaryText: "Girasoles Elite, Zapopan",
            fullAddress: ""
        )) { item in
            
        }
    }
}


enum AddressSearchType {
    case address
    case city
}
