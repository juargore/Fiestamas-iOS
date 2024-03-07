//
//  Quote.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ParentQuote: Codable, Hashable {
    let title: String
    let products: [QuoteProductsInformation]
    let bids: [PreBidForQuote]
    var noteBook: String
    var eventCost: String
    var advancePayment: String
    var status: String

    init(title: String, products: [QuoteProductsInformation], bids: [PreBidForQuote], noteBook: String, eventCost: String, advancePayment: String, status: String) {
        self.title = title
        self.products = products
        self.bids = bids
        self.noteBook = noteBook
        self.eventCost = eventCost
        self.advancePayment = advancePayment
        self.status = status
    }
}

struct QuoteProductsInformation: Codable, Hashable {
    let quantity: String
    let description: String
    let price: String
    let subtotal: String

    init(quantity: String, description: String, price: String, subtotal: String) {
        self.quantity = quantity
        self.description = description
        self.price = price
        self.subtotal = subtotal
    }

    func toItemQuoteRequest() -> ItemQuoteRequest {
        let qty = Int(quantity) ?? 0
        let priceValue = Int(price) ?? 0
        let subTotalValue = qty * priceValue
        return ItemQuoteRequest(qty: qty, description: description, price: priceValue, subTotal: subTotalValue)
    }
}

struct PreBidForQuote: Codable, Hashable {
    var bid: Int
    let id_user: String
    let status: String
    let user_role: String

    init(bid: Int, id_user: String, status: String, user_role: String) {
        self.bid = bid
        self.id_user = id_user
        self.status = status
        self.user_role = user_role
    }
    
    func toBidForQuote() -> BidForQuote {
        return BidForQuote(
            bid: self.bid,
            id_user: self.id_user,
            status: self.status,
            user_role: self.user_role,
            isTemp: false
        )
    }
}

struct BidForQuote: Codable, Hashable {
    var bid: Int
    let id_user: String
    let status: String
    let user_role: String
    var isTemp: Bool

    init(bid: Int, id_user: String, status: String, user_role: String, isTemp: Bool) {
        self.bid = bid
        self.id_user = id_user
        self.status = status
        self.user_role = user_role
        self.isTemp = isTemp
    }
    
    
}
