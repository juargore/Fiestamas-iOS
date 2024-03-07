//
//  PendingServicesDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct PendingServicesDialog: View {
    
    var vm: MainPartyViewModel
    var isActive: Bool
    var serviceId: String
    var servicesByEvents: [MyPartyService]
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
            }.onTapGesture {
                onDismiss()
            }
            Text("Servicios pendientes")
                .fontWeight(.semibold)
                .font(.system(size: 17))
            Text("No es posible eliminar el servicio porque que aún tienes los siguientes eventos pendientes:")
                .font(.subheadline)
                .padding(.top, 5)
                .padding(.bottom, 12)
            VStack {
                ForEach(servicesByEvents) { item in
                    CardPendingService(item: item)
                }
            }
            .padding(.bottom, 12)
            // TODO: Toggle button here
        }
        .padding()
    }
}


struct CardPendingService: View {
    
    var item: MyPartyService
    
    var body: some View {
        HStack {
            Text("\(item.event_data?.name_event_type ?? "") \(item.event_data?.name ?? "")")
                .font(.tiny)
            let date = convertStringToDate(item.date)
            let dateFormatted = convertDateUTC(date: date)
            Spacer()
            Text(dateFormatted.0)
                .font(.tiny)
                .foregroundColor(Color.hotPink)
            Text(dateFormatted.1)
                .font(.tiny)
                .foregroundColor(Color.hotPink)
        }
    }
}
