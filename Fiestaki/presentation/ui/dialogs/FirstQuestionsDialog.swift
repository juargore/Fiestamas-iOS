//
//  EventInfoView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 06/06/23.
//

import SwiftUI
import CoreLocation

struct FirstQuestionsDialog: View {
    
    var vms: ServicesCategoriesViewModel
    var isForProvider: Bool
    var serviceCategory: ServiceCategory?
    var onContinueClicked: (FirstQuestions, Event?) -> Void
    var onDismissDialog: () -> Void
    
    @State var festejadosNames = ""
    @State var numberOfGuests = ""
    @State var city = ""
    @State var location: Location? = nil
    @State var selectedEvent: Event? = nil
    @State var selectedEventString = "Seleccione un evento"
    
    @State var showDatePicker = false
    @State var showTimePicker = false
    @State var isShowingAutocomplete = false
    
    @State var date = ""
    @State var time = ""
    @State var dateSwift: Date = Date.now
    @State var timeSwift: Date = Date.now
    
    @State private var showToast = false
    @State private var messageToast = ""
    
    var minimumDate: Date {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        return currentDate
    }
    
    init(
        vms: ServicesCategoriesViewModel,
        isForProvider: Bool,
        serviceCategory: ServiceCategory?,
        onContinueClicked: @escaping (FirstQuestions, Event?) -> Void,
        onDismissDialog: @escaping () -> Void
    ) {
        self.vms = vms
        self.isForProvider = isForProvider
        self.serviceCategory = serviceCategory
        self.onContinueClicked = onContinueClicked
        self.onDismissDialog = onDismissDialog
    }

    var body: some View {
            VStack() {
                HStack {
                    Spacer()
                    Text("X")
                        .foregroundColor(.black)
                }.onTapGesture {
                    onDismissDialog()
                }
                
                if serviceCategory != nil {
                    let events = vms.eventsByService
                    var eventsStrings: [String] = ["Seleccione un evento"]
                    let _ = eventsStrings.append( contentsOf: events.map { $0.name! } )
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 40)
                            .foregroundColor(Color.white)
                        
                        Picker("Evento", selection: $selectedEventString) {
                            ForEach(eventsStrings, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    .padding(.bottom, 6)
                }
                
                CustomTextField(placeholder: "Nombre(s) del festejado(s)", text: $festejadosNames)
                    .padding(.bottom, 6)
                
                CustomTextField(placeholder: "Fecha del evento", text: $date)
                    .foregroundColor(.ashGray)
                    .onTapGesture {
                        showDatePicker = true
                    }
                    .padding(.bottom, 6)
                
                CustomTextField(placeholder: "Hora del evento", text: $time)
                    .foregroundColor(.ashGray)
                    .onTapGesture {
                        showTimePicker = true
                    }
                    .padding(.bottom, 6)
                
                CustomTextField(placeholder: "Cantidad de invitados", text: $numberOfGuests)
                    .keyboardType(.numberPad)
                    .padding(.bottom, 6)
                
                CustomTextField(placeholder: "Ciudad del evento", text: $city)
                    .foregroundColor(.ashGray)
                    .onTapGesture {
                        isShowingAutocomplete.toggle()
                    }

                FiestakiButton(text: "Continuar") {
                    if !isForProvider {
                        if serviceCategory != nil {
                            if selectedEventString == "Seleccione un evento" {
                                messageToast = "Seleccione un evento de la lista"
                                showToast = true
                                return
                            }
                            // an event type was selected from drop down list
                            vms.eventsByService.forEach { event in
                                if event.name == selectedEventString {
                                    selectedEvent = event
                                    return
                                }
                            }
                        }
                        
                        if festejadosNames.isEmpty {
                            messageToast = "El nombre del festejado no puede estar vacío"
                            showToast = true
                            return
                        }
                        if date.isEmpty {
                            messageToast = "El campo fecha no puede estar vacío"
                            showToast = true
                            return
                        }
                        if numberOfGuests.isEmpty {
                            messageToast = "El campo invitados no puede estar vacío"
                            showToast = true
                            return
                        }
                        if city.isEmpty {
                            messageToast = "El campo ciudad está vacío o es inválido"
                            showToast = true
                            return
                        }
                    }
                    
                    onContinueClicked(
                        FirstQuestions(
                            festejadosNames: festejadosNames,
                            date: stringToISO8601(inputDate: "\(date) \(time)"),
                            numberOfGuests: numberOfGuests,
                            city: city,
                            location: location
                        ),
                        serviceCategory != nil ? selectedEvent : nil
                    )
                }
                .padding(.top, 12)
                .padding(.bottom, 1)
            }
            .padding(10)
            .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
            .onAppear {
                if serviceCategory != nil {
                    vms.getEventsByServiceCategoryId(serviceId: serviceCategory!.id!)
                }
            }
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    DatePicker(
                        "Selecciona una fecha",
                        selection: $dateSwift,
                        in: minimumDate...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    //.frame(width: 300)

                    FiestakiButton(text: "Listo") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy MM dd"
                        let formattedDate = formatter.string(from: dateSwift)
                        date = formattedDate.replacingOccurrences(of: " ", with: "-")
                        showDatePicker = false
                    }
                }
                .presentationDetents([.medium, .medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showTimePicker) {
                VStack {
                    Spacer()
                    DatePicker(
                        "Selecciona una hora",
                        selection: $timeSwift,
                        in: minimumDate...,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .frame(width: 300)
                    
                    Spacer()

                    FiestakiButton(text: "Listo") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "h:mm"
                        let formattedDate = formatter.string(from: timeSwift)
                        time = formattedDate
                        showTimePicker = false
                    }
                }
                .presentationDetents([.medium, .medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingAutocomplete) {
                AddressAutoCompleteScreen(
                    searchType: AddressSearchType.city,
                    onCitySelected: { address, nCity in
                        if address != nil {
                            city = nCity
                            location = address?.location
                        }
                        isShowingAutocomplete = false
                    }
                )
                .presentationDetents([.medium, .medium])
                .presentationDragIndicator(.visible)
            }
    }
}
