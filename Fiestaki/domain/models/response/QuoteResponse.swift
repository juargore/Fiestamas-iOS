//
//  QuoteResponse.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct CreateQuoteResponse: Codable, Hashable {
    let id: String
    let notes: String
    let id_service_event: String
    let noteBook: String
}

struct GetQuoteResponse: FirebaseModel, Codable, Hashable {
    var id: String?
    let deposit: Int
    let elements: [ItemQuoteRequest]
    var bids: [PreBidForQuote]
    let id_service_event: String
    let noteBook_client: String?
    let noteBook_provider: String?
    let notes: String
    let type: String
    let allow_edit: Bool

    init(id: String, deposit: Int, elements: [ItemQuoteRequest], bids: [PreBidForQuote], id_service_event: String, noteBook_client: String?, noteBook_provider: String?, notes: String, type: String, allow_edit: Bool) {
        self.id = id
        self.deposit = deposit
        self.elements = elements
        self.bids = bids
        self.id_service_event = id_service_event
        self.noteBook_client = noteBook_client
        self.noteBook_provider = noteBook_provider
        self.notes = notes
        self.type = type
        self.allow_edit = allow_edit
    }

    init() {
        self.init(id: "", deposit: 0, elements: [], bids: [], id_service_event: "", noteBook_client: nil, noteBook_provider: nil, notes: "", type: "CLASSIC", allow_edit: true)
    }
}
