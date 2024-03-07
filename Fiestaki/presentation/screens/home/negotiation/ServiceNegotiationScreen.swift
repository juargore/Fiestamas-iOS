//
//  ServiceNegotiationScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/14/23.
//

import SwiftUI

struct ServiceNegotiationScreen: View {
    
    @EnvironmentObject var navigation: ServicesByEventsNavGraph
    @StateObject var viewModel = ServiceNegotiationViewModel()
    @StateObject var authViewModel = AuthViewModel()
    
    @State var user: FirebaseUserDb? = nil
    @State var numberOfNotifications = 0
    
    @State var alreadyExistsQuote = false
    @State var serviceEventStatus = ""
    @State var alreadyAcceptedQuote = false
    @State var isUsingExpressQuote = false
    @State private var showToast = false
    @State private var messageToast = ""
    
    @State private var showStatusOptionsDialog = false
    @State private var showNewOrEditQuoteDialog = false
    @State private var showNewOrEditExpressQuoteDialog = false
    @State private var showNoteBookDialog = false
    @State private var noteBookDialogIsEditable = false
    @State private var showYesNoDialogToCancelStatus = false
    @State private var showYesNoDialogToEditQuote = false
    @State private var showProgressDialog = false
    
    var myPartyService: MyPartyService
    var isProvider: Bool
    var clientOrProviderId: String?
    
    init(myPartyService: MyPartyService, isProvider: Bool) {
        
        self.myPartyService = myPartyService
        self.isProvider = isProvider
        self.clientOrProviderId = myPartyService.id_provider
        if isProvider {
            self.clientOrProviderId = myPartyService.event_data?.id_client
        }
    }
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            ScrollView(.vertical) {
                VStack {
                    mainHeader(
                        userIsLoggedIn: user != nil,
                        username: user?.name ?? "",
                        showBackButton: true,
                        showNotificationIcon: true,
                        numberOfNotifications: numberOfNotifications,
                        iconNotification: "ic_envelope",
                        onNotificationClicked: {
                            navigation.navigate(
                                to: .onNavigateChatScreen(
                                    myPartyService: myPartyService,
                                    clientId: myPartyService.id_client ?? "",
                                    providerId: myPartyService.id_provider ?? "",
                                    serviceEventId: myPartyService.id ?? "",
                                    serviceId: myPartyService.id_service ?? "",
                                    isProvider: isProvider,
                                    clientEventId: myPartyService.id_client_event ?? "",
                                    eventName: "\(myPartyService.event_data?.name_event_type ?? "") \(myPartyService.event_data?.name ?? "")"
                                )
                            )
                        },
                        onBackButtonClicked: {
                            navigation.navigateBack()
                        }
                    )
                    
                    TopEventInformation(myPartyService: myPartyService)
                    
                    VStack {
                        TopContactInformation(vma: authViewModel, clientId: clientOrProviderId)
                        
                        if !isProvider {
                            Rectangle()
                                .frame(height: 0.5)
                                .padding(.horizontal, 18)
                                .padding(.bottom, 12)
                                .foregroundColor(.black)
                            
                            TopServiceInformation(myPartyService: myPartyService)
                        }
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .leading) {
                                if isProvider {
                                    if viewModel.cQuote == nil {
                                        ProviderContentEmpty(
                                            vm: viewModel,
                                            myPartyService: myPartyService,
                                            onShowNewExpressQuoteDialog: {
                                                showNewOrEditExpressQuoteDialog = true
                                            },
                                            onShowNewQuoteDialog: {
                                                showNewOrEditQuoteDialog = true
                                            }
                                        )
                                    } else {
                                        VStack {
                                            HStack {
                                                HStack {
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 14, height: 14)
                                                            .foregroundColor(Color.white)
                                                        
                                                        Image("ic_edit_fiestaki")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                    }
                                                    
                                                    Text("Edita cotización")
                                                        .font(.footnote)
                                                        .foregroundColor(Color.white)
                                                        .padding(.vertical, 10)
                                                }
                                                .padding(.horizontal, 10)
                                                .background(Color.gray)
                                                .cornerRadius(14)
                                                .onTapGesture {
                                                    if alreadyExistsQuote {
                                                        if viewModel.cQuote?.allow_edit == true {
                                                            debugPrint("AQUI: aún no se acepta -> se puede editar")
                                                            if isUsingExpressQuote {
                                                                showNewOrEditExpressQuoteDialog = true
                                                            } else {
                                                                showNewOrEditQuoteDialog = true
                                                            }
                                                        } else {
                                                            debugPrint("AQUI: Ya se aceptó la cotización y no se puede editar -> Preguntar al cliente")
                                                            showYesNoDialogToEditQuote = true
                                                        }
                                                    }
                                                }
                                                
                                                Spacer()
                                            }.padding(.top, 6)
                                            
                                            ScreenTabForBid(
                                                vm: viewModel,
                                                myPartyService: myPartyService,
                                                cQuote: viewModel.cQuote!,
                                                isProvider: true,
                                                userOrProviderId: myPartyService.id_provider ?? "",
                                                status: serviceEventStatus,
                                                serviceEventId: myPartyService.id ?? "",
                                                onShowStatusOptionsDialog: {
                                                    showStatusOptionsDialog = true
                                                },
                                                onNoteBookClicked: {
                                                    showNoteBookDialog = true
                                                    noteBookDialogIsEditable = true
                                                },
                                                onNotesQuoteClicked: {
                                                    showNoteBookDialog = true
                                                    noteBookDialogIsEditable = false
                                                },
                                                showProgress: { value in
                                                    showProgressDialog = value
                                                }
                                            )
                                        }
                                        
                                    }
                                } else {
                                    if viewModel.cQuote == nil {
                                        ClientContentEmpty(
                                            vm: viewModel,
                                            myPartyService: myPartyService,
                                            onRequestedQuoteFinished: { msg in
                                                messageToast = msg
                                                showToast = true
                                            }
                                        )
                                    } else {
                                        ScreenTabForBid(
                                            vm: viewModel,
                                            myPartyService: myPartyService,
                                            cQuote: viewModel.cQuote!,
                                            isProvider: false,
                                            userOrProviderId: myPartyService.event_data?.id_client ?? "",
                                            status: serviceEventStatus,
                                            serviceEventId: myPartyService.id ?? "",
                                            onShowStatusOptionsDialog: {
                                                showStatusOptionsDialog = true
                                            },
                                            onNoteBookClicked: {
                                                showNoteBookDialog = true
                                                noteBookDialogIsEditable = true
                                            },
                                            onNotesQuoteClicked: {
                                                showNoteBookDialog = true
                                                noteBookDialogIsEditable = false
                                            },
                                            showProgress: { value in
                                                showProgressDialog = value
                                            }
                                        )
                                    }
                                }
                            }
                            Spacer()
                        }
                        .background(Color(UIColor(hex: "#F1F2F2")))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
        }
        //.frame(maxWidth: UIScreen.height)
        .onAppear {
            viewModel.getQuote(serviceEventId: myPartyService.id)
            viewModel.getMyPartyService(serviceEventId: myPartyService.id ?? "") { cPartyService in
                alreadyExistsQuote = viewModel.cQuote != nil
                serviceEventStatus = cPartyService?.status ?? ""
                alreadyAcceptedQuote = viewModel.cQuote?.allow_edit == false
                isUsingExpressQuote = viewModel.cQuote?.type == "EXPRESS"
            }
            var senderId = myPartyService.id_provider ?? ""
            if isProvider {
                senderId = myPartyService.id_client ?? ""
            }
            viewModel.getUnreadCounterChatMessagesByServiceEvent(
                serviceEventId: myPartyService.id!,
                senderId: senderId
            ) { counter in
                self.numberOfNotifications = counter
            }
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
        }
        .onChange(of: user) { newValue in
            guard newValue != nil else { return }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .popUpDialog(isShowing: $showNewOrEditQuoteDialog, dialogContent: {
            NewQuoteOrEditDialog(
                isEditingData: alreadyExistsQuote,
                quote: viewModel.cQuote,
                editableList: viewModel.cQuote?.elements.map{ $0.toQuoteProductsInformation() },
                onSendNewQuoteClicked: { items, providerNotes, total in
                    showNewOrEditQuoteDialog = false
                    showProgressDialog = true
                    viewModel.createNewQuote(
                        userId: user?.id ?? "",
                        serviceEventId: myPartyService.id ?? "",
                        elements: items,
                        providerNotes: providerNotes,
                        total: total,
                        isExpress: false,
                        onFinished: { message in
                            showProgressDialog = false
                            if !message.isEmpty {
                                messageToast = message
                                showToast = true
                            }
                        }
                    )
                },
                onEditQuoteClicked: { nItems, oldSize, providerNotes, personalNotesClient, personalNotesProvider, _ in
                    showNewOrEditQuoteDialog = false
                    showProgressDialog = true
                    viewModel.editQuote(
                        serviceEventId: myPartyService.id ?? "",
                        quoteId: viewModel.cQuote?.id ?? "",
                        sizeOldElements: oldSize,
                        newElements: nItems,
                        isExpress: false,
                        onFinished: { message in
                            showProgressDialog = false
                            if !message.isEmpty {
                                messageToast = message
                                showToast = true
                            }
                        }
                    )
                },
                onDismiss: {
                    showNewOrEditQuoteDialog = false
                }
            )
        })
        .popUpDialog(isShowing: $showNewOrEditExpressQuoteDialog, dialogContent: {
            NewExpressQuoteOrEditDialog(
                isEditingData: alreadyExistsQuote,
                originalTotal: String(myPartyService.price ?? 0),
                originalNotes: viewModel.cQuote?.notes ?? "",
                onSendNewQuoteClicked: { providerNotes, total in
                    showNewOrEditExpressQuoteDialog = false
                    showProgressDialog = true
                    viewModel.createNewQuote(
                        userId: user?.id ?? "",
                        serviceEventId: myPartyService.id ?? "",
                        elements: [QuoteProductsInformation(
                            quantity: "1",
                            description: myPartyService.description ?? "",
                            price: String(total),
                            subtotal: String(total))
                        ],
                        providerNotes: providerNotes,
                        total: total,
                        isExpress: true,
                        onFinished: { message in
                            showProgressDialog = false
                            if !message.isEmpty {
                                messageToast = message
                                showToast = true
                            }
                        }
                    )
                },
                onEditQuoteClicked: { providerNotes, total in
                    showNewOrEditExpressQuoteDialog = false
                    showProgressDialog = true
                    viewModel.editExpressQuote(
                        serviceEventId: myPartyService.id ?? "",
                        quotationId: viewModel.cQuote?.id ?? "",
                        userId: user?.id ?? "",
                        totalBid: total,
                        providerNotes: providerNotes,
                        notesClient: viewModel.cQuote?.noteBook_client,
                        notesProvider: viewModel.cQuote?.noteBook_provider,
                        onFinished: { message in
                            showProgressDialog = false
                            if !message.isEmpty {
                                messageToast = message
                                showToast = true
                            }
                        }
                    )
                },
                onDismiss: {
                    showNewOrEditExpressQuoteDialog = false
                }
            )
        })
        .popUpDialog(isShowing: $showStatusOptionsDialog, dialogContent: {
            OptionsQuoteDialog(
                onActionSelected: { option in
                    switch option {
                    case .Hired, .Pending:
                        showStatusOptionsDialog = false
                        showProgressDialog = true
                        updateStatus(
                            vmt: viewModel,
                            serviceEventId: myPartyService.id ?? "",
                            status: option,
                            onCompleted: { msg in
                                showProgressDialog = false
                                if !msg.isEmpty {
                                    messageToast = msg
                                    showToast = true
                                }
                            }
                         )
                    case .Cancel:
                        showStatusOptionsDialog = false
                        showYesNoDialogToCancelStatus = true
                    }
                },
                onDismiss: {
                    showStatusOptionsDialog = false
                }
            )
        })
        .popUpDialog(isShowing: $showNoteBookDialog, dialogContent: {
            NoteBookDialog(
                savedNotes: isProvider ? viewModel.cQuote?.noteBook_provider ?? "" : viewModel.cQuote?.noteBook_client ?? "",
                isEditable: noteBookDialogIsEditable,
                onSaveClicked: { notes in
                    showNoteBookDialog = false
                    if viewModel.cQuote?.id != nil {
                        showProgressDialog = true
                        viewModel.addNotesToQuote(
                            serviceEventId: myPartyService.id!,
                            quoteId: viewModel.cQuote!.id!,
                            providerNotes: viewModel.cQuote!.notes,
                            personalNotesClient: isProvider ? viewModel.cQuote!.noteBook_client : notes,
                            personalNotesProvider: isProvider ? notes : viewModel.cQuote!.noteBook_provider,
                            onComplete: { message in
                                showProgressDialog = false
                                if !message.isEmpty {
                                    messageToast = message
                                    showToast = true
                                }
                            }
                        )
                    }
                },
                onDismiss: {
                    showNoteBookDialog = false
                }
            )
        })
        .popUpDialog(isShowing: $showYesNoDialogToCancelStatus, dialogContent: {
            YesNoDialog(
                message: "¿Confirma que desea cancelar el servicio para el evento seleccionado?",
                icon: "ic_question_circled",
                onDismiss: {
                    showYesNoDialogToCancelStatus = false
                },
                onOk: {
                    showYesNoDialogToCancelStatus = false
                    showProgressDialog = true
                    updateStatus(
                        vmt: viewModel,
                        serviceEventId: myPartyService.id ?? "",
                        status: OptionsQuote.Cancel,
                        onCompleted: { msg in
                            showProgressDialog = false
                            if !msg.isEmpty {
                                messageToast = msg
                                showToast = true
                            }
                        }
                    )
                }
            )
        })
        .popUpDialog(isShowing: $showYesNoDialogToEditQuote, dialogContent: {
            YesNoDialog(
                title: "Requiere aprobación",
                message: "Esta oferta ya fue aceptada. Para poder editarla, requieres la aprobación del cliente.\n\n¿Deseas solicitar la aprobación del cliente?",
                icon: "ic_question_circled",
                onDismiss: {
                    showYesNoDialogToEditQuote = false
                },
                onOk: {
                    showYesNoDialogToEditQuote = false
                    if viewModel.cQuote != nil {
                        showProgressDialog = true
                        viewModel.requestEditQuoteFromProviderToClient(
                            serviceEventId: myPartyService.id ?? "",
                            quoteId: viewModel.cQuote!.id!,
                            onFinished: { message in
                                showProgressDialog = false
                                if !message.isEmpty {
                                    messageToast = message
                                    showToast = true
                                }
                            })
                    }
                }
            )
        })
        .popUpDialog(isShowing: $showProgressDialog, dialogContent: {
            ProgressDialog(isVisible: showProgressDialog)
        })
    }
}


struct ClientContentEmpty: View {
    
    var vm: ServiceNegotiationViewModel
    var myPartyService: MyPartyService
    var onRequestedQuoteFinished: (String) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Text("Tu proveedor no ha generado")
                .font(.subheadline)
                .foregroundColor(.black)
            
            Text("aún una cotización")
                .font(.subheadline)
                .foregroundColor(.black)
            
            VStack {
                Text("Solicitar cotización")
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .background(Color.hotPink)
            .cornerRadius(12)
            .onTapGesture {
                vm.requestQuoteFromClientToProvider(
                    serviceEventId: myPartyService.id ?? "",
                    onFinished: { _ in
                        onRequestedQuoteFinished("Se ha solicitado la cotización con éxito")
                    }
                )
            }
            Spacer()
        }
    }
}

struct ScreenTabForBid: View {
    
    var vm: ServiceNegotiationViewModel
    var myPartyService: MyPartyService
    var cQuote: GetQuoteResponse
    var isProvider: Bool
    var userOrProviderId: String
    var status: String
    var serviceEventId: String
    var onShowStatusOptionsDialog: () -> Void
    var onNoteBookClicked: () -> Void
    var onNotesQuoteClicked: () -> Void
    var showProgress: (Bool) -> Void
    
    @State var finalCost = 0
    @State var alreadyAccepted = false
    @State var anticipo = "0"
    
    @State private var showToast = false
    @State private var messageToast = ""
    
    init(vm: ServiceNegotiationViewModel,
         myPartyService: MyPartyService,
         cQuote: GetQuoteResponse,
         isProvider: Bool,
         userOrProviderId: String,
         status: String,
         serviceEventId: String,
         onShowStatusOptionsDialog: @escaping () -> Void,
         onNoteBookClicked: @escaping () -> Void,
         onNotesQuoteClicked: @escaping () -> Void,
         showProgress: @escaping (Bool) -> Void
    ) {
        self.vm = vm
        self.myPartyService = myPartyService
        self.cQuote = cQuote
        self.isProvider = isProvider
        self.userOrProviderId = userOrProviderId
        self.status = status
        self.serviceEventId = serviceEventId
        self.onShowStatusOptionsDialog = onShowStatusOptionsDialog
        self.onNoteBookClicked = onNoteBookClicked
        self.onNotesQuoteClicked = onNotesQuoteClicked
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack {
            VStack {
                VStack {
                    ProductsInformationDetails(list: cQuote.elements)
                    Rectangle()
                        .frame(height: 0.5)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 15)
                        .foregroundColor(.gray)
                    
                    LazyVStack {
                    if isProvider {
                        ForEach(Array(vm.bids.enumerated()), id: \.offset) { i, bid in
                            if bid.status == "NEGOTIATING" {
                                if bid.user_role == "provider" {
                                    CardRightYellowBid(
                                        item: bid,
                                        isButtonEnabled: vm.getIsButtonEnabled(i, vm.bids),
                                        showCostOnEdittext: vm.getShowCost(i, vm.bids),
                                        text: "Mi Oferta",
                                        onButtonClicked: { mBid in }
                                    )
                                } else {
                                    CardLeftGreenBid(
                                        item: bid,
                                        showPinkButton: false,
                                        isButtonEnabled: vm.getIsButtonEnabled2(i, vm.bids),
                                        // only if is last item is enabled,
                                        isEdittextEnabled: false,
                                        showCostOnEdittext: true,
                                        onButtonClicked: { mBid in
                                            showProgress(true)
                                            vm.acceptOffer(
                                                serviceEventId: serviceEventId,
                                                quoteId: cQuote.id ?? "",
                                                userId: userOrProviderId,
                                                onFinished: { response in
                                                    showProgress(false)
                                                    if !response.isEmpty {
                                                        messageToast = response
                                                        showToast = true
                                                    }
                                                }
                                            )
                                        },
                                        onPinkButtonClicked: { /* no applicable */ }
                                    )
                                    
                                    // add yellow button under the accepted one
                                    if (vm.getIsButtonEnabled2(i, vm.bids)) {
                                        CardRightYellowBid(
                                            item: bid,
                                            isButtonEnabled: true,
                                            showCostOnEdittext: false,
                                            text: "Mi Oferta",
                                            onButtonClicked: { mBid in
                                                if mBid.bid == 0 {
                                                    messageToast = "Ingresa una cantidad a ofrecer"
                                                    showToast = true
                                                } else {
                                                    // provider made a new offer
                                                    showProgress(true)
                                                    vm.createNewOffer(
                                                        serviceEventId: serviceEventId,
                                                        quoteId: cQuote.id ?? "",
                                                        bid: mBid.bid,
                                                        userId: userOrProviderId,
                                                        onFinish: { b in
                                                            showProgress(false)
                                                        }
                                                    )
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                            //else
                            if bid.status == "ACCEPTED" {
                                CardBothAcceptedBid(item: bid) {
                                    alreadyAccepted = true
                                    finalCost = bid.bid
                                    updateStatus(
                                        vmt: vm,
                                        serviceEventId: serviceEventId,
                                        status: OptionsQuote.Hired,
                                        onCompleted: { msg in
                                            /* nothing since status is updated realtime on db */
                                        }
                                     )
                                }
                            }
                        }
                        Spacer()
                    }
                        //else
                        if !isProvider {
                            ForEach(Array(vm.bids.enumerated()), id: \.offset) { i, bid in
                                if bid.status == "NEGOTIATING" {
                                    if bid.user_role == "client" {
                                        CardRightYellowBid(
                                            item: bid,
                                            isButtonEnabled: bid.isTemp,
                                            showCostOnEdittext: !bid.isTemp,
                                            text: vm.getBidText(bid),
                                            onButtonClicked: { nBid in
                                                if nBid.bid == 0 {
                                                    messageToast = "Ingrese una cantidad a ofrecer"
                                                    showToast = true
                                                } else {
                                                    // client made a new offer
                                                    showProgress(true)
                                                    vm.createNewOffer(
                                                        serviceEventId: serviceEventId,
                                                        quoteId: cQuote.id ?? "",
                                                        bid: nBid.bid,
                                                        userId: userOrProviderId,
                                                        onFinish: { a in
                                                            showProgress(false)
                                                        }
                                                    )
                                                }
                                            }
                                        )
                                    } else {
                                        CardLeftGreenBid(
                                            item: bid,
                                            showPinkButton: vm.showPinkButton(i, vm.bids),
                                            isButtonEnabled: vm.getIsButtonEnabled2(i, vm.bids),
                                            // only if is last item is enabled
                                            isEdittextEnabled: false,
                                            showCostOnEdittext: true,
                                            onButtonClicked: { nBid in
                                                // client accepted offer
                                                showProgress(true)
                                                vm.acceptOffer(
                                                    serviceEventId: serviceEventId,
                                                    quoteId: cQuote.id ?? "",
                                                    userId: userOrProviderId,
                                                    onFinished: { response in
                                                        showProgress(false)
                                                        if !response.isEmpty {
                                                            messageToast = response
                                                            showToast = true
                                                        }
                                                    }
                                                )
                                            },
                                            onPinkButtonClicked: {
                                                // create local bid to show on yellow block
                                                vm.bids.append(
                                                    BidForQuote(
                                                        bid: 0,
                                                        id_user: "",
                                                        status: "NEGOTIATING",
                                                        user_role: "client",
                                                        isTemp: true
                                                    )
                                                )
                                            }
                                        )
                                        
                                        // add yellow button under the accepted one
                                        if vm.shouldAddYellowButtonUnderTheAcceptedOne(i, vm.bids) {
                                            let _ = vm.bids.append(
                                                BidForQuote(
                                                    bid: 0,
                                                    id_user: "",
                                                    status: "NEGOTIATING",
                                                    user_role: "client",
                                                    isTemp: true
                                                )
                                            )
                                            /*CardRightYellowBid(
                                             item: bid,
                                             isButtonEnabled: true,
                                             showCostOnEdittext: false,
                                             text: "Mi Oferta",
                                             onButtonClicked: { nBid in
                                             if nBid.bid == 0 {
                                             messageToast = "Ingrese una cantidad a ofrecer"
                                             showToast = true
                                             } else {
                                             // provider made a new offer
                                             showProgress(true)
                                             vm.createNewOffer(
                                             serviceEventId: serviceEventId,
                                             quoteId: cQuote.id ?? "",
                                             bid: nBid.bid,
                                             userId: userOrProviderId,
                                             onFinish: { a in
                                             showProgress(false)
                                             }
                                             )
                                             }
                                             }
                                             )*/
                                        }
                                    }
                                }
                                //else
                                if bid.status == "ACCEPTED" {
                                    CardBothAcceptedBid(item: bid) {
                                        alreadyAccepted = true
                                        finalCost = bid.bid
                                        updateStatus(
                                            vmt: vm,
                                            serviceEventId: serviceEventId,
                                            status: OptionsQuote.Hired,
                                            onCompleted: { msg in
                                                /* nothing since status is updated realtime on db */
                                            }
                                        )
                                    }
                                }
                            }
                            Spacer()
                        }
                    
                    } // cierra LazyVStack
                }
                .background(Color.white)
                .cornerRadius(12)
                
                HStack {
                    VStack {
                        Text("Estatus")
                            .font(.tiny)
                            .foregroundColor(Color.gray)
                        
                        HStack {
                            Spacer()
                            Text(status.getStatusName())
                                .font(.caption)
                                .padding(.horizontal, 16)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .frame(height: 34)
                        .background(status.getStatus().getStatusColor())
                        .cornerRadius(10)
                        .onTapGesture {
                            onShowStatusOptionsDialog()
                        }
                    }
                    Spacer()
                    if alreadyAccepted {
                        VStack {
                            Text("Costo evento")
                                .font(.tiny)
                                .foregroundColor(Color.gray)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .frame(height: 34)
                                    .foregroundColor(.gray.opacity(0.5))

                                TextField("", value: $finalCost, formatter: NumberFormatter())
                                    .font(.body)
                                    .frame(height: 34)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .disabled(true)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    /*
                    VStack {
                        Text("Anticipo")
                            .font(.tiny)
                            .foregroundColor(Color.gray)
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 1)
                                .frame(height: 34)
                                .foregroundColor(.gray.opacity(0.5))

                            TextField("", text: $anticipo)
                                .font(.body)
                                .frame(height: 34)
                                .background(Color.white)
                                .cornerRadius(10)
                                .multilineTextAlignment(.center)
                        }
                    }*/
                }
                .padding(.top, 10)
                .padding(.bottom, 2)
                
                
                HStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Notas importantes")
                                .font(.tiny)
                                .foregroundColor(Color.black)
                            Spacer()
                        }
                        
                        Text(cQuote.notes)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .onTapGesture {
                        onNotesQuoteClicked()
                    }
                    
                    Rectangle()
                        .frame(width: 0.5, height: 40)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text("Block de Notas")
                                .font(.tiny)
                                .foregroundColor(Color.black)
                            Spacer()
                        }
                        
                        Text(cQuote.noteBook_client ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .onTapGesture {
                        onNoteBookClicked()
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            /*
            self.bids = self.cQuote.bids.map {
                $0.toBidForQuote()
            }
            debugPrint("AQUI: Size: ", self.bids.count)
            */
        }
    }
}

func updateStatus(
    vmt: ServiceNegotiationViewModel,
    serviceEventId: String,
    status: OptionsQuote,
    onCompleted: @escaping (String) -> Void
) {
    vmt.updateServiceStatus(serviceEventId: serviceEventId, status: status, onFinished: { response in
        onCompleted(response)
    })
}

struct ProviderContentEmpty: View {
    
    var vm: ServiceNegotiationViewModel
    var myPartyService: MyPartyService
    var onShowNewExpressQuoteDialog: () -> Void
    var onShowNewQuoteDialog: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color.white)
                        Image("ic_add_fiestaki")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                    
                    Text("Nueva cotización")
                        .font(.footnote)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 10)
                    Spacer()
                }
                .background(Color.gray)
                .cornerRadius(14)
                .onTapGesture {
                    onShowNewQuoteDialog()
                }
                
                Spacer()
                
                HStack(alignment: VerticalAlignment.center) {
                    Spacer()
                    Text("Cotización express")
                        .font(.footnote)
                        .foregroundColor(Color.white)
                        .padding(.vertical, 10)
                    Spacer()
                }
                .background(Color.hotPink)
                .cornerRadius(14)
                .onTapGesture {
                    onShowNewExpressQuoteDialog()
                }
                
                Spacer()
            }
            .padding(.top, 12)
            Spacer()
        }
    }
}
