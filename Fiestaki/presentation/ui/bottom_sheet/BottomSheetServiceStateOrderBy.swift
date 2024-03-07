//
//  BottomSheetServiceStateOrderBy.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/24/23.
//

import Foundation
import SwiftUI

struct BottomSheetServiceStateOrderBy: View {
    
    var onItemSelected: (BottomServiceStatus) -> Void
    var mList: [BottomServiceStatus]
    
    init(
        mList: [BottomServiceStatus] = [
            BottomServiceStatus(status: ServiceStatus.All, name: "Todos"),
            BottomServiceStatus(status: ServiceStatus.Hired, name: "Contratados"),
            BottomServiceStatus(status: ServiceStatus.Pending, name: "Pendientes"),
            BottomServiceStatus(status: ServiceStatus.Canceled, name: "Cancelados")
        ],
        onItemSelected: @escaping (BottomServiceStatus) -> Void
    ) {
        self.mList = mList
        self.onItemSelected = onItemSelected
    }
    
    var body: some View {
        VStack {
            LazyVStack {
                ForEach(mList, id: \.self) { item in
                    HStack {
                        Text("●")
                            .foregroundColor(item.status.getStatusColor())
                            .font(.body)
                            .padding(.leading, 24)
                            .padding(.trailing, 10)
                        
                        Text(item.name)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .onTapGesture {
                        onItemSelected(item)
                    }
                }
            }
        }
    }
}
