//
//  QuoteRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ItemQuoteRequest: Codable, Hashable {
    let qty: Int
    let description: String
    let price: Int
    let subTotal: Int

    init(qty: Int, description: String, price: Int, subTotal: Int) {
        self.qty = qty
        self.description = description
        self.price = price
        self.subTotal = subTotal
    }

    func toQuoteProductsInformation() -> QuoteProductsInformation {
        return QuoteProductsInformation(quantity: String(qty), description: description, price: String(price), subtotal: String(subTotal))
    }
}

struct ItemsQuoteRequest: Codable, Hashable {
    let elements: [ItemQuoteRequest]

    init(elements: [ItemQuoteRequest]) {
        self.elements = elements
    }
}

struct ItemsExpressQuoteRequest: Codable, Hashable {
    let type: String

    init(type: String) {
        self.type = type
    }
}

struct ItemBidOfferRequest: Codable, Hashable {
    let bid: Int
    let id_user: String

    init(bid: Int, id_user: String) {
        self.bid = bid
        self.id_user = id_user
    }
}

struct ItemBidAcceptedRequest: Codable, Hashable {
    let status: String
    let id_user: String

    init(status: String, id_user: String) {
        self.status = status
        self.id_user = id_user
    }
}

struct ItemUpdateStatusRequest: Codable, Hashable {
    let status: String

    init(status: String) {
        self.status = status
    }
}

struct ItemAddNotesToQuoteRequest: Codable, Hashable {
    let notes: String
    let deposit: Int
    let noteBook_client: String
    let noteBook_provider: String

    init(notes: String, deposit: Int, noteBook_client: String, noteBook_provider: String) {
        self.notes = notes
        self.deposit = deposit
        self.noteBook_client = noteBook_client
        self.noteBook_provider = noteBook_provider
    }
}

