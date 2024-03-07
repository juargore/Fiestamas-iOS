//
//  AddEditProviderFirstStepScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/27/23.
//

import SwiftUI

struct AddEditProviderFirstStepScreen: View {
    
    @ObservedObject var viewModel = DetailsServiceViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var serviceId: String?
    var screenInfo: ScreenInfo?
    
    @State var service: Service? = nil
    @State var user: FirebaseUserDb? = nil
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            
            VStack {
                servicesHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    title: service == nil ? "Agregar Servicio" : "Editar Servicio",
                    subTitle: service == nil ? viewModel.getLikedStrings(screenInfo: screenInfo) : service!.name,
                    smallSubtitle: true
                ) {
                    navigation.navigateBack()
                }
                
                if service != nil {
                    let screenInfo2 = viewModel.getScreenInfo2(service: service!)
                    let addressData = AddressData(
                        address: service!.address,
                        city: "",
                        state: "",
                        postalCode: "",
                        country: "",
                        latitude: String(service?.lat ?? "0.0"),
                        longitude: String(service?.lng ?? "0.0")
                    )
                    ProviderView(
                        screenInfo: screenInfo2,
                        serviceId: serviceId,
                        isEditing: true,
                        addressData: addressData,
                        onNavigateToAddServiceProvider: { serviceProviderData in
                            let images = screenInfo2.service?.images ?? []
                            let videos = screenInfo2.service?.videos ?? []
                            let newScreenInfo = ScreenInfo(
                                role: screenInfo2.role,
                                startedScreen: screenInfo2.startedScreen,
                                prevScreen: screenInfo2.prevScreen,
                                event: screenInfo2.event,
                                questions: screenInfo2.questions,
                                serviceCategory: screenInfo2.serviceCategory,
                                clientEventId: screenInfo2.clientEventId,
                                serviceType: screenInfo2.serviceType,
                                subService: screenInfo2.subService,
                                service: Service(id: service!.id!, name: service!.name)
                            )
                            navigation.navigate(
                                to: .onNavigateAddServiceProvider2(newScreenInfo, serviceProviderData, images, videos, true)
                            )
                        }
                    )
                } else {
                    if screenInfo != nil {
                        ProviderView(
                            screenInfo: screenInfo!,
                            serviceId: serviceId,
                            isEditing: false,
                            addressData: nil,
                            onNavigateToAddServiceProvider: { serviceProviderData in
                                navigation.navigate(
                                    to: .onNavigateAddServiceProvider2(screenInfo!, serviceProviderData, [], [], false)
                                )
                            }
                        )
                    }
                    
                }
                
            }
        }
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
            if serviceId != nil {
                viewModel.getServiceDetails(serviceId: serviceId!, onFinished: { service in
                    self.service = service
                })
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ProviderView: View {
    
    @ObservedObject var detailsViewModel = DetailsServiceViewModel()
    @ObservedObject var viewModel = ServicesViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    
    var screenInfo: ScreenInfo
    var serviceId: String?
    var isEditing: Bool
    var onNavigateToAddServiceProvider: (ServiceProviderData) -> Void
    
    @State var addressData: AddressData?
    @State var serviceName = ""
    @State var service: Service?
    @State var providerDb: FirebaseUserDb? = nil
    @State var attributesSelected: [String] = []
    @State var optionsUnity: [String] = ["Persona", "Pieza", "Kg", "Evento"]
    
    @State var name = ""
    @State var cAddress = ""
    @State var description = ""
    @State var min = ""
    @State var max = ""
    @State var cost = ""
    @State var showToast = false
    @State var messageToast = ""
    
    @State var attributes: [Attribute] = []
    @State var isShowingAutocomplete = false
    @State var useProviderAddress: Bool = false
    @State var providerAddress: String = ""
    @State var providerLat: String = ""
    @State var providerLng: String = ""
    
    // pz | person | kg | event
    @State var unit: String = "Persona"
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(
        screenInfo: ScreenInfo,
        serviceId: String?,
        isEditing: Bool,
        addressData: AddressData?,
        onNavigateToAddServiceProvider: @escaping (ServiceProviderData) -> Void
    ) {
        self.screenInfo = screenInfo
        self.serviceId = serviceId
        self.isEditing = isEditing
        self.addressData = addressData
        self.onNavigateToAddServiceProvider = onNavigateToAddServiceProvider
        
        
    }
    
    var body: some View {
        VStack {
            VStack {
                ScrollView(.vertical) {
                    VStack {
                        Text(isEditing ? "Tipo de servicio que ofreces" : "Tipos de \(serviceName) que ofreces")
                            .foregroundColor(Color.hotPink)
                            .font(.headline)
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(attributes, id: \.self) { attribute in
                                let startSelected = viewModel.getStartSelected(isEditing, service, attribute)
                                CheckboxFiestamas(text: attribute.name, startChecked: startSelected) { checked in
                                    if checked {
                                        attributesSelected.append(attribute.id!)
                                    } else {
                                        attributesSelected.removeAll { $0 == attribute.id! }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 20)
                        
                        Text("Información del Servicio")
                            .foregroundColor(Color.hotPink)
                            .font(.headline)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 50)
                                .foregroundColor(Color.white)
                            
                            CustomTextField(placeholder: "Nombre", text: $name)
                        }
                        .padding(.bottom, 5)
                        
                        if !useProviderAddress {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(height: 50)
                                    .foregroundColor(Color.white)
                                
                                CustomTextField(placeholder: "Domicilio", text: $cAddress)
                                    .foregroundColor(.ashGray)
                                    .onTapGesture {
                                        isShowingAutocomplete.toggle()
                                    }
                            }
                            .padding(.bottom, 5)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 50)
                                .foregroundColor(Color.white)
                            
                            CustomTextField(placeholder: "Descripción", text: $description)
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(height: 50)
                                    .foregroundColor(Color.white)
                                
                                CustomTextField(placeholder: "Min. Asist", text: $min)
                                    .keyboardType(.numberPad)
                            }
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(height: 50)
                                    .foregroundColor(Color.white)
                                
                                CustomTextField(placeholder: "Max. Asist", text: $max)
                                    .keyboardType(.numberPad)
                            }
                        }
                        .padding(.bottom, 5)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 50)
                                .foregroundColor(Color.white)
                            
                            CustomTextField(placeholder: "Precio", text: $cost)
                                .keyboardType(.numberPad)
                        }
                        .padding(.bottom, 5)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 50)
                                .foregroundColor(Color.white)
                            
                            Picker("Por", selection: $unit) {
                                ForEach(optionsUnity, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.bottom, 20)
                        
                        FiestakiButton(text: "Continuar", action: {
                            if name.isEmpty {
                                messageToast = "El nombre no puede estar vacío"
                                showToast = true
                                return
                            }
                            if cAddress.isEmpty {
                                messageToast = "El campo dirección no puede estar vacío"
                                showToast = true
                                return
                            }
                            if description.isEmpty {
                                messageToast = "El campo descripción no puede estar vacío"
                                showToast = true
                                return
                            }
                            if min.isEmpty {
                                messageToast = "El mínimo de asistentes no puede estar vacío"
                                showToast = true
                                return
                            }
                            if max.isEmpty {
                                messageToast = "El máximo de asistentes no puede estar vacío"
                                showToast = true
                                return
                            }
                            if Int(min)! > Int(max)! {
                                messageToast = "El número mínimo de asistentes es mayor al máximo"
                                showToast = true
                                return
                            }
                            if cost.isEmpty {
                                messageToast = "El costo no puede estar vacío"
                                showToast = true
                                return
                            }
                            if attributesSelected.isEmpty {
                                messageToast = "Seleccione al menos un atributo"
                                showToast = true
                                return
                            }
                            
                            let data = ServiceProviderData(
                                name: name,
                                addressData: addressData,
                                description: description,
                                minCapacity: min,
                                maxCapacity: max,
                                cost: cost,
                                unit: unit,
                                attributes: attributesSelected
                            )
                            onNavigateToAddServiceProvider(data)
                        })
                        .padding(.bottom, 10)
                    }
                    .padding()
                }
            }
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.7), radius: 5)
            .background(Color.lavenderMist)
            .padding(.all, 12)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.hotPink)
                    .shadow(color: .gray.opacity(0.7), radius: 5)
                    .padding(.all, 12)
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            self.service = screenInfo.service
            self.name = isEditing ? service?.name ?? "" : ""
            self.cAddress = addressData?.address ?? ""
            self.description = isEditing ? service?.description ?? "" : ""
            self.min = isEditing ? String(service?.min_attendees ?? 0) : ""
            self.max = isEditing ? String(service?.max_attendees ?? 0) : ""
            self.cost = isEditing ? String(service?.price ?? 0) : ""
            self.unit = optionsUnity.first!
            
            if screenInfo.subService != nil {
                viewModel.getAttributesBySubServiceId(subServiceId: screenInfo.subService!.id!) { attributes in
                    self.attributes = attributes
                    self.attributes.forEach { attribute in
                        if viewModel.getStartSelected(isEditing, service, attribute) {
                            attributesSelected.append(attribute.id!)
                        }
                    }
                }
                self.serviceName = screenInfo.subService!.name
            } else if screenInfo.serviceType != nil {
                viewModel.getAttributesByServiceTypeId(serviceTypeId: screenInfo.serviceType!.id!) { attributes in
                    self.attributes = attributes
                    self.attributes.forEach { attribute in
                        if viewModel.getStartSelected(isEditing, service, attribute) {
                            attributesSelected.append(attribute.id!)
                        }
                    }
                }
                self.serviceName = screenInfo.serviceType!.name
            } else {
                if screenInfo.serviceCategory?.id != nil {
                    viewModel.getAttributesByServiceCategoryId(serviceCategoryId: screenInfo.serviceCategory!.id!) { attributes in
                        self.attributes = attributes
                        self.attributes.forEach { attribute in
                            if viewModel.getStartSelected(isEditing, service, attribute) {
                                attributesSelected.append(attribute.id!)
                            }
                        }
                    }
                } else {
                    debugPrint("AQUI: Error! Id es null")
                }
                self.serviceName = screenInfo.serviceCategory?.name ?? ""
            }
            
            if screenInfo.service?.id_provider != nil {
                authViewModel.getFirebaseProviderDb(providerId: screenInfo.service!.id_provider, onResult: { provider in
                    self.providerDb = provider
                    
                    if let address = self.providerDb?.address {
                        providerAddress = address
                    }
                    
                    if let lat = self.providerDb?.lat {
                        providerLat = lat
                    }
                    
                    if let lng = self.providerDb?.lng {
                        providerLng = lng
                    }
                    
                    if useProviderAddress {
                        if !providerAddress.isEmpty {
                            self.addressData = AddressData(
                                address: providerAddress,
                                city: "",
                                state: "",
                                postalCode: "",
                                country: "",
                                latitude: providerLat,
                                longitude: providerLng
                            )
                        } else {
                            debugPrint("La dirección del proveedor está vacía")
                        }
                    }
                })
            }
            
            if serviceId != nil {
                if service != nil {
                    addressData = AddressData(
                        address: service!.address,
                        city: "",
                        state: "",
                        postalCode: "",
                        country: "",
                        latitude: service!.lat ?? "",
                        longitude: service!.lng ?? ""
                    )
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $isShowingAutocomplete) {
            AddressAutoCompleteScreen(
                searchType: AddressSearchType.address,
                onAddressSelected: { address in
                    cAddress = address?.line1 ?? ""
                    addressData = AddressData(
                        address: address?.line1 ?? "",
                        city: address?.city ?? "",
                        state: address?.state ?? "",
                        postalCode: address?.zipcode ?? "",
                        country: address?.country ?? "",
                        latitude: address?.location?.lat ?? "",
                        longitude: address?.location?.lng ?? ""
                    )
                    isShowingAutocomplete = false
                }
            )
            .presentationDetents([.medium, .medium])
            .presentationDragIndicator(.visible)
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }
}


struct CheckboxFiestamas: View {
    
    @State var checkedState: Bool
    @State var text: String
    var onStateChanged: (Bool) -> Void
    
    init(
        text: String,
        startChecked: Bool = false,
        onStateChanged: @escaping (Bool) -> Void = {_ in }
    ) {
        self.text = text
        self.checkedState = startChecked
        self.onStateChanged = onStateChanged
    }
    
    var body: some View {
        HStack {
            Toggle(isOn: $checkedState) {
                Text(text)
            }
            .toggleStyle(iOSCheckboxToggleStyle())
            .onChange(of: checkedState, perform: { value in
                onStateChanged(value)
            })
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(Color.hotPink)
                configuration.label
                    .foregroundColor(Color.black)
            }
        })
    }
}
