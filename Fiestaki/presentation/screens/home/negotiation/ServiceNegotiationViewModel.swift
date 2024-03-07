//
//  ServiceNegotiationViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/14/23.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

final class ServiceNegotiationViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var navigationPath = NavigationPath()
    @Published var eventUseCase = EventUseCase()
    @Published var serviceUseCase = ServiceUseCase()
    @Published var messageUseCase = MessageUseCase()
    
    @Published var unreadMessagesCount = 0
    @Published var myPartyService: MyPartyService? = nil
    @Published var cQuote: GetQuoteResponse? = nil
    @Published var bids: [BidForQuote] = []
    
    
    func getMyPartyService(serviceEventId: String, onFinished: @escaping (MyPartyService?) -> Void) {
        eventUseCase
            .getMyPartyService(serviceEventId: serviceEventId)
            .sink { _ in } receiveValue: { myPartyService in
                self.myPartyService = myPartyService
                onFinished(myPartyService)
            }.store(in: &disposables)
    }
    
    func requestQuoteFromClientToProvider(serviceEventId: String, onFinished: @escaping (String) -> Void) {
        serviceUseCase
            .requestQuoteFromClientToProvider(serviceEventId: serviceEventId)
            .sink { result in
                switch result {
                case .finished:
                    onFinished("Se ha solicitado la cotización con éxito!")
                case .failure(let error):
                    onFinished(error.localizedDescription)
                }
            } receiveValue: { _ in }.store(in: &disposables)
    }
    
    func requestEditQuoteFromProviderToClient(
        serviceEventId: String,
        quoteId: String,
        onFinished: @escaping (String) -> Void
    ) {
        serviceUseCase
            .requestEditQuoteFromProviderToClient(serviceEventId: serviceEventId, quoteId: quoteId)
            .sink { result in
                switch result {
                case .finished:
                    onFinished("")
                case .failure(let error):
                    onFinished(error.localizedDescription)
                }
            } receiveValue: { _ in }.store(in: &disposables)
    }
    
    func getQuote(serviceEventId: String?
                   //onFinished: @escaping (GetQuoteResponse?) -> Void
    ) {
        if serviceEventId == nil {
            debugPrint("AQUI: Error, serviceEventId is nil")
        } else {
            //debugPrint("AQUI: All good, serviceEventId is ", serviceEventId as Any)
            serviceUseCase
                .getQuoteByServiceEvent(serviceEventId: serviceEventId!)
                .sink { _ in } receiveValue: { quoteResponse in
                    if quoteResponse.first != nil {
                        self.cQuote = quoteResponse.first
                        self.bids = self.cQuote?.bids.map { $0.toBidForQuote() } ?? []
                    } else {
                        self.cQuote = nil
                        self.bids = []
                    }
                    debugPrint("AQUI: QuoteId: ", self.cQuote?.id ?? "")
                    //onFinished(self.cQuote)
                }.store(in: &disposables)
        }
    }
    
    func editExpressQuote(
        serviceEventId: String,
        quotationId: String?,
        userId: String,
        totalBid: Int,
        providerNotes: String?,
        notesClient: String?,
        notesProvider: String?,
        onFinished: @escaping (String) -> Void
    ) {
        if quotationId != nil {
            serviceUseCase
                .updateExpressQuote(serviceEventId: serviceEventId, quotationId: quotationId!, providerNotes: providerNotes, notesClient: notesClient, notesProvider: notesProvider)
                .sink { result in
                    switch result {
                    case .finished:
                        self.createNewOffer(
                            serviceEventId: serviceEventId,
                            quoteId: quotationId!,
                            bid: totalBid,
                            userId: userId,
                            onFinish: { r in }
                        )
                        onFinished("Cotización actualizada!")
                    case .failure(let error):
                        onFinished(error.localizedDescription)
                    }
                } receiveValue: { _ in }.store(in: &disposables)
        } else {
            onFinished("quoteId is nil")
        }
    }
    
    func createNewQuote(
        userId: String,
        serviceEventId: String,
        elements: [QuoteProductsInformation],
        providerNotes: String,
        total: Int,
        isExpress: Bool,
        onFinished: @escaping (String) -> Void
    ) {
        serviceUseCase
            .createNewQuote(id_service_event: serviceEventId, isExpress: isExpress, elements: elements)
            .sink { result in } receiveValue: { response in
                debugPrint("AQUI: ServiceEventId: ", serviceEventId)
                debugPrint("AQUI: QuoteId: ", response)
                self.createNewOffer(
                    serviceEventId: serviceEventId,
                    quoteId: response,
                    bid: total,
                    userId: userId,
                    onFinish: { res in
                        if providerNotes.isEmpty {
                            onFinished("Oferta enviada con éxito!")
                        } else {
                            self.addNotesToQuote(
                                serviceEventId: serviceEventId,
                                quoteId: response,
                                providerNotes: providerNotes,
                                onComplete: { msg in onFinished(msg) }
                            )
                        }
                    }
                )
            }
            .store(in: &disposables)
    }
    
    func createNewOffer(
        serviceEventId: String,
        quoteId: String,
        bid: Int,
        userId: String,
        onFinish: @escaping (Bool) -> Void
    ) {
        serviceUseCase
            .createNewOffer(id_service_event: serviceEventId, id_quotation: quoteId, bid: bid, userId: userId)
            .sink { result in
                switch result {
                case .finished:
                    onFinish(true)
                case .failure(_):
                    onFinish(false)
                }
            } receiveValue: { _ in }.store(in: &disposables)
    }
    
    func editQuote(
        serviceEventId: String,
        quoteId: String,
        sizeOldElements: Int,
        newElements: [QuoteProductsInformation],
        providerNotes: String? = nil,
        personalNotesClient: String? = nil,
        personalNotesProvider: String? = nil,
        isExpress: Bool,
        onFinished: @escaping (String) -> Void
    ) {
        serviceUseCase
            .updateElementsInQuote(id_service_event: serviceEventId, id_quotation: quoteId, sizeOldElements: sizeOldElements, newElements: newElements)
            .sink { response in
                self.addNotesToQuote(
                    serviceEventId: serviceEventId,
                    quoteId: quoteId,
                    providerNotes: providerNotes,
                    personalNotesClient: personalNotesClient,
                    personalNotesProvider: personalNotesProvider,
                    onComplete: { msg in onFinished(msg) }
                )
            } receiveValue: { bool in }
            .store(in: &disposables)
    }
    
    func addNotesToQuote(
        serviceEventId: String,
        quoteId: String,
        providerNotes: String? = nil,
        personalNotesClient: String? = nil,
        personalNotesProvider: String? = nil,
        onComplete: @escaping (String) -> Void
    ) {
        serviceUseCase
            .addNotesToExistingQuote(serviceEventId: serviceEventId, quotationId: quoteId, providerNotes: providerNotes, noteBook: personalNotesClient, notesClient: personalNotesClient, notesProvider: personalNotesProvider)
            .sink { result in
                switch result {
                case .finished:
                    onComplete("Nota agregada con éxito!")
                case .failure(let error):
                    onComplete(error.localizedDescription)
                }
            } receiveValue: { response in }
            .store(in: &disposables)
    }
    
    func acceptOffer(
        serviceEventId: String,
        quoteId: String,
        userId: String,
        onFinished: @escaping (String) -> Void
    ) {
        serviceUseCase
            .acceptOffer(serviceEventId: serviceEventId, quotationId: quoteId, userId: userId)
            .sink { result in
            switch result {
            case .finished:
                onFinished("Cotización aceptada!")
            case .failure(let error):
                onFinished(error.localizedDescription)
            }
        } receiveValue: { response in }
        .store(in: &disposables)
    }
    
    func updateServiceStatus(
        serviceEventId: String,
        status: OptionsQuote,
        onFinished: @escaping  (String) -> Void)
    {
        serviceUseCase
            .updateServiceStatus(serviceEventId: serviceEventId, status: status)
            .sink { result in
            switch result {
            case .finished:
                onFinished("Estatus actualizado!")
            case .failure(let error):
                onFinished(error.localizedDescription)
            }
        } receiveValue: { response in }
        .store(in: &disposables)
    }
    
    func getUnreadCounterChatMessagesByServiceEvent(
        serviceEventId: String,
        senderId: String,
        onComplete: @escaping (Int) -> Void
    ) {
        messageUseCase
            .getUnreadCounterChatMessagesByServiceEvent(serviceEventId: serviceEventId, senderId: senderId)
            .sink { _ in } receiveValue: { counter in
                self.unreadMessagesCount = counter
                onComplete(counter)
            }.store(in: &disposables)
    }
    
    
    func getIsButtonEnabled(_ i: Int, _ bids: [BidForQuote]) -> Bool {
        var buttonEnabled = false
        if (i == bids.count - 1 && bids.count > 1) {
            buttonEnabled = true
        }
        return buttonEnabled
    }
    
    func getShowCost(_ i: Int, _ bids: [BidForQuote]) -> Bool {
        var showCost = false
        if (i <= bids.count - 1) {
            showCost = true
        }
        return showCost
    }
    
    func getIsButtonEnabled2(_ i: Int, _ bids: [BidForQuote]) -> Bool {
        return i == bids.count - 1
    }
    
    func getBidText(_ bid: BidForQuote) -> String {
        var text = "Mi Oferta"
        if bid.isTemp {
            text = "Ofrezco"
        }
        return text
    }
    
    func showPinkButton(_ i: Int, _ bids: [BidForQuote]) -> Bool {
        i == 0 && bids.count == 1
    }
    
    func shouldAddYellowButtonUnderTheAcceptedOne(_ i: Int, _ bids: [BidForQuote]) -> Bool {
        let c1: Bool = i == bids.count - 1
        let c2: Bool = i != 0
        return c1 && c2
    }
}
