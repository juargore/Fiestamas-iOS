//
//  testDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct AdminServicesDialog: View {
    
    var viewModel: MainPartyViewModel
    var allServicesProvider: [Service]
    var servicesByEvents: [MyPartyService]
    var onDismissDialog: () -> Void
    var onNewServiceClicked: () -> Void
    var onEditServiceClicked: (Service) -> Void
    
    @State var selectedService: Service? = nil
    @State var pendingServices: [MyPartyService] = []
    @State var showPendingServicesDialog = false
    @State var showDeleteDialog = false
    
    init(vm: MainPartyViewModel,
         allServicesProvider: [Service],
         servicesByEvents: [MyPartyService],
         onDismissDialog: @escaping () -> Void,
         onNewServiceClicked: @escaping () -> Void,
         onEditServiceClicked: @escaping (Service) -> Void
    ) {
        viewModel = vm
        self.allServicesProvider = allServicesProvider
        self.servicesByEvents = servicesByEvents
        self.onDismissDialog = onDismissDialog
        self.onNewServiceClicked = onNewServiceClicked
        self.onEditServiceClicked = onEditServiceClicked
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .foregroundColor(.black)
            }.onTapGesture {
                onDismissDialog()
            }
            
            Text("Administración de mis servicios")
                .fontWeight(.semibold)
                .font(.system(size: 18))
                .foregroundColor(.black)

                VStack {
                    ForEach(Array(allServicesProvider.enumerated()), id: \.offset) { i, item in
                        CardServicesProvider(
                            vm: viewModel,
                            item: item,
                            index: i,
                            onEdit: { it in
                                selectedService = it
                                onEditServiceClicked(it)
                            },
                            onDelete: { service in
                                selectedService = service
                                servicesByEvents.forEach { a in
                                    if a.id_service == selectedService?.id {
                                        pendingServices.append(a)
                                    }
                                }
                                if pendingServices.isEmpty {
                                    showDeleteDialog = true
                                } else {
                                    showPendingServicesDialog = true
                                }
                            }
                        )
                    }
                }
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.gray, lineWidth: 1)
                )
            
            HStack {
                VStack(alignment: HorizontalAlignment.center) {
                    Image("ic_add_fiestaki")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("Agregar")
                        .font(.tiny)
                        .foregroundColor(.black)
                    Text("Nuevo Servicio")
                        .font(.tiny)
                        .foregroundColor(.black)
                }
                Spacer()
            }.onTapGesture {
                onNewServiceClicked()
            }
        }
        .padding(10)
        .popUpDialog(isShowing: $showPendingServicesDialog, padding: 5, dialogContent: {
            PendingServicesDialog(
                vm: viewModel,
                isActive: selectedService?.active ?? false,
                serviceId: selectedService?.id ?? "",
                servicesByEvents: pendingServices,
                onDismiss: {
                    pendingServices.removeAll()
                    showPendingServicesDialog = false
                }
            )
        })
        .popUpDialog(isShowing: $showDeleteDialog, padding: 5, dialogContent: {
            YesNoDialog(
                message: "¿Confirma que desea eliminar el servicio seleccionado?",
                icon: "ic_question_circled",
                onDismiss: {
                    showDeleteDialog = false
                },
                onOk: {
                    showDeleteDialog = false
                }
            )
        })
    }
}


struct CardServicesProvider: View {
    
    var vm: MainPartyViewModel
    var item: Service
    var index: Int
    var onEdit: (Service) -> Void
    var onDelete: (Service) -> Void
    
    @State private var enabled: Bool
    
    init(vm: MainPartyViewModel, item: Service, index: Int,
         onEdit: @escaping (Service) -> Void, onDelete: @escaping (Service) -> Void) {
        self.vm = vm
        self.item = item
        self.index = index
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.enabled = item.active == true
    }
    
    var body: some View {
        VStack {
            if index != 0 {
                Divider()
            }
            
            HStack {
                HStack {
                    Toggle("", isOn: $enabled)
                        .labelsHidden()
                        .tint(Color.hotPink)
                    Text(item.name)
                        .font(.small)
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Image("ic_edit")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("Editar")
                        .font(.tiny)
                        .foregroundColor(Color.hotPink)
                }
                .onTapGesture {
                    onEdit(item)
                }
                VStack {
                    Image("ic_trash_can")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("Eliminar")
                        .font(.tiny)
                        .foregroundColor(Color.hotPink)
                }
                .onTapGesture {
                    onDelete(item)
                }
            }
            .padding(10)
            HStack {
                let linkedString = "\(item.name_service_category ?? "") > \(item.name_service_type ?? "") > \(item.name_sub_service_type ?? "") > \(item.name)"
                let cleanLinkedString = linkedString.replacingOccurrences(of: "  >", with: "")
                Text(cleanLinkedString)
                    .font(.moreTiny)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                Spacer()
            }
        }
        .onChange(of: enabled) { value in
            vm.enableOrDisableService(serviceId: item.id!)
        }
    }
}
