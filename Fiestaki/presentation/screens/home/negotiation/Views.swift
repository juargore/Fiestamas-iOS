//
//  Views.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/14/23.
//

import Foundation
import SwiftUI

struct TopEventInformation: View {
    var myPartyService: MyPartyService

    var body: some View {
        let stringDate = convertStringToDate(myPartyService.date)
        let (date, _) = convertDateToDateAndHour(date: stringDate)
        let (_, b) = convertDateToDateAndHour(date: stringDate)

        HStack {
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    if let festejadosName = myPartyService.event_data?.name,
                       let eventName = myPartyService.event_data?.name_event_type {
                        Text("\(eventName) \(festejadosName)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)

                        Text(myPartyService.address ?? "")
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "calendar")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)

                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)

                    Text(b)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }

                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)

                    Text("\(String(myPartyService.event_data?.attendees ?? "0")) P")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                }
            }
            .padding(12)
            .background(Color(UIColor(hex: "#8852DB")))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }
}

struct TopContactInformation: View {
    
    var vma: AuthViewModel
    var clientId: String?
    
    @State var provider: FirebaseUserDb? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("\(provider?.name ?? "") \(provider?.last_name ?? "")")
                .foregroundColor(.black)
            
            HStack {
                HStack {
                    Image(systemName: "phone")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.hotPink)
                        .padding(.leading, 14)
                    
                    Text(provider?.phone_one ?? "")
                        .font(.footnote)
                        .foregroundColor(.hotPink)
                        .padding(.trailing, 14)
                        .padding(.vertical, 6)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.ashGray, lineWidth: 0.8))
                
                HStack {
                    Image(systemName: "envelope")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.hotPink)
                        .padding(.leading, 14)
                    
                    Text(provider?.email ?? "")
                        .font(.footnote)
                        .foregroundColor(.hotPink)
                        .lineLimit(1)
                        .padding(.trailing, 14)
                        .padding(.vertical, 6)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.ashGray, lineWidth: 0.8))
                
            }
        }
        .padding()
        .onAppear {
            vma.getFirebaseProviderDb(providerId: clientId ?? "") { user in
                provider = user
            }
        }
    }
}

struct TopServiceInformation: View {
    var myPartyService: MyPartyService

    var body: some View {
        HStack {
            let photo = myPartyService.image ?? ""
            RemoteImage(urlString: photo)
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 0.8))

            VStack(alignment: .leading, spacing: 8) {
                let type = myPartyService.service_category_name ?? ""
                let name = myPartyService.name ?? ""
                
                Text("\(type) - \(name)")
                    .font(.footnote)
                    .foregroundColor(.black)
                
                HStack(spacing: 3) {
                    ForEach(1..<(myPartyService.rating ?? 5), id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.tiny)
                            .foregroundColor(.hotPink)
                    }
                    Spacer()
                }
                .padding(.bottom, 5)
        
                HStack() {
                    Image(systemName: "location")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.hotPink)
                    
                    Text(myPartyService.address ?? "")
                        .foregroundColor(.hotPink)
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 12)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct ProductsInformationDetails: View {
    
    var list: [ItemQuoteRequest]

    var body: some View {
        VStack(spacing: 4) {
            CardProductInformation(
                item : QuoteProductsInformation(
                    quantity: "Cant.",
                    description: "Descripción",
                    price: "Precio",
                    subtotal: "Subtotal"
                ),
                isTitle: true
            )

            ForEach(list, id: \.self) { itemQuoteRequest in
                CardProductInformation(
                    item: QuoteProductsInformation(
                        quantity: "\(itemQuoteRequest.qty)",
                        description: itemQuoteRequest.description,
                        price: "\(itemQuoteRequest.price)",
                        subtotal: "\(itemQuoteRequest.subTotal)"
                    )
                )
            }
        }
        .padding(4)
    }
}

struct BottomData: View {
    var providerNotes: String
    var noteBook: String
    var alreadyAccepted: Bool
    var finalEventCost: Int
    var status: String
    var onOptionsClicked: () -> Void
    var onNoteBookClicked: () -> Void
    var onNotesQuoteClicked: () -> Void

    @State private var advance = ""

    let textSize: CGFloat = 11
    let uiHeight: CGFloat = 40
    let uiSidePadding: CGFloat = 4

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                VStack(spacing: 5) {
                    Text("Estatus")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }

                if alreadyAccepted {
                    VStack(spacing: 5) {
                        Text("Costo evento")
                        TextField("Costo", text: .constant(String(finalEventCost)))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity, minHeight: uiHeight)
                            .padding(uiSidePadding)
                            .background(Color.white)
                            .border(Color.gray, width: 1)
                            .cornerRadius(12)
                    }

                    VStack(spacing: 5) {
                        Text("Anticipo")
                        TextField("Anticipo", text: $advance)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity, minHeight: uiHeight)
                            .padding(uiSidePadding)
                            .background(Color.white)
                            .border(Color.gray, width: 1)
                            .cornerRadius(12)
                    }
                }
            }
            .frame(maxHeight: .infinity * 0.55)

            Spacer(minLength: 5)

            HStack {
                VStack {
                    Text("Notas importantes")
                    Text(providerNotes)
                        .onTapGesture { onNotesQuoteClicked() }
                }
                .frame(maxWidth: .infinity * 0.495)

                Rectangle()
                    .frame(width: 1, height: .infinity)
                    .foregroundColor(Color(.systemGray4))

                VStack {
                    Text("Block de Notas")
                    Text(noteBook)
                        .onTapGesture { onNoteBookClicked() }
                }
                .frame(maxWidth: .infinity * 0.495)
            }
            .frame(maxHeight: .infinity * 0.45)
        }
        .padding(.horizontal, 4)
    }
}


struct CardProductInformation: View {
    
    var item: QuoteProductsInformation
    var isTitle: Bool = false
    var addRemoveButton: Bool = false
    var onRemoveClicked: ((QuoteProductsInformation) -> Void)?

    var body: some View {
        HStack {
            if addRemoveButton && !isTitle {
                Image("ic_remove_filled")
                    .resizable()
                    .frame(width: 17, height: 17)
                    .onTapGesture {
                        onRemoveClicked?(item)
                    }
            }
            
            if addRemoveButton && isTitle {
                Spacer()
            }

            Text(item.quantity)
                .font(.caption)
                .foregroundColor(isTitle ? Color.gray : Color.black)
                .frame(maxWidth: .infinity * 0.15)

            Text(item.description)
                .font(.caption)
                .foregroundColor(isTitle ? Color.gray : Color.black)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity * 0.50)

            Text(item.price)
                .font(.caption)
                .foregroundColor(isTitle ? Color.gray : Color.black)
                .frame(maxWidth: .infinity * 0.15)

            Text(item.subtotal)
                .font(.caption)
                .foregroundColor(isTitle ? Color.gray : Color.black)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity * 0.20)
        }
        .padding(.vertical, 1)
    }
}

struct CardRightYellowBid: View {
    
    @State private var bid: String
    
    let yellowColor = Color(UIColor(hex: "#FFF200"))
    var item: BidForQuote
    var isButtonEnabled: Bool
    var showCostOnEdittext: Bool
    var text: String
    var onButtonClicked: (BidForQuote) -> Void

    init(
        item: BidForQuote,
        isButtonEnabled: Bool,
        showCostOnEdittext: Bool,
        text: String,
        onButtonClicked: @escaping (BidForQuote) -> Void
    ) {
        self.item = item
        self.isButtonEnabled = isButtonEnabled
        self.showCostOnEdittext = showCostOnEdittext
        self.text = text
        self.onButtonClicked = onButtonClicked
        
        if showCostOnEdittext {
            bid = String(item.bid)
        } else {
            bid = ""
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .frame(width: 90, height: 34)
                        .foregroundColor(.gray.opacity(0.5))

                    TextField("", text: $bid)
                        .font(.body)
                        .frame(width: 90, height: 34)
                        .background(isButtonEnabled ? Color.white : Color.white.opacity(0.9))
                        .foregroundColor(isButtonEnabled ? .black : .gray)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .disabled(!isButtonEnabled)
                }
                .padding(.horizontal, 4)
                
                Text(text)
                    .padding(.horizontal, 20)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .onTapGesture {
                        if isButtonEnabled {
                            var itemCopy = item
                            if bid.isEmpty {
                                itemCopy.bid = 0
                            } else {
                                itemCopy.bid = Int(bid) ?? 0
                            }
                            onButtonClicked(itemCopy)
                        }
                    }
            }
            .frame(height: 40)
            .background(isButtonEnabled ? yellowColor : yellowColor.opacity(0.8))
            .cornerRadius(8)
        }
        .padding(.horizontal, 12)
    }
}

// Helper function to filter decimal input
func filterDecimalInput(_ text: String) -> String {
    // Implement your logic to filter decimal input
    return text
}

struct CardLeftGreenBid: View {
    
    @State private var bid: String
    
    let greenColor = Color(UIColor(hex: "#27AD5F"))
    var item: BidForQuote
    var showPinkButton: Bool
    var isButtonEnabled: Bool
    var isEdittextEnabled: Bool
    var showCostOnEdittext: Bool
    var onButtonClicked: (BidForQuote) -> Void
    var onPinkButtonClicked: () -> Void

    init(
        item: BidForQuote,
        showPinkButton: Bool,
        isButtonEnabled: Bool,
        isEdittextEnabled: Bool,
        showCostOnEdittext: Bool,
        onButtonClicked: @escaping (BidForQuote) -> Void,
        onPinkButtonClicked: @escaping () -> Void
    ) {
        self.item = item
        self.showPinkButton = showPinkButton
        self.isButtonEnabled = isButtonEnabled
        self.isEdittextEnabled = isEdittextEnabled
        self.showCostOnEdittext = showCostOnEdittext
        self.onButtonClicked = onButtonClicked
        self.onPinkButtonClicked = onPinkButtonClicked
        
        if showCostOnEdittext {
            bid = String(item.bid)
        } else {
            bid = ""
        }
    }
    
    var body: some View {
        HStack {
            HStack() {
                Image("ic_check_circle_white")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.white)
                    .padding(.leading, 12)
                
                Text("Acepto")
                    .padding(.horizontal, 8)
                    .font(.subheadline)
                    .foregroundColor(Color.white)
                    .onTapGesture {
                        if isButtonEnabled {
                            var itemCopy = item
                            if bid.isEmpty {
                                itemCopy.bid = 0
                            } else {
                                itemCopy.bid = Int(bid) ?? 0
                            }
                            onButtonClicked(itemCopy)
                        }
                    }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .frame(width: 90, height: 34)
                        .foregroundColor(.gray.opacity(0.5))

                    TextField("", text: $bid)
                        .font(.body)
                        .frame(width: 90, height: 34)
                        .background(isButtonEnabled ? Color.white : Color.white.opacity(0.9))
                        .foregroundColor(isButtonEnabled ? .black : .gray)
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .disabled(!isButtonEnabled)
                }
                .padding(.horizontal, 4)
            }
            .frame(height: 40)
            .background(isButtonEnabled ? greenColor : greenColor.opacity(0.8))
            .cornerRadius(8)
            
            if showPinkButton {
                Button(action: {
                    onPinkButtonClicked()
                }, label: {
                    Text("···")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 30)
                        .frame(height: 30)
                        .background(Color.hotPink)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 12)
    }
}


struct CardBothAcceptedBid: View {
    
    var item: BidForQuote
    var onCardShowed: () -> Void
    
    @State var bid: String
    let greenColor = Color(UIColor(hex: "#27AD5F"))
    
    init(item: BidForQuote, onCardShowed: @escaping () -> Void) {
        self.item = item
        self.onCardShowed = onCardShowed
        bid = String(item.bid)
    }

    var body: some View {
        HStack {
            HStack {
                HStack {
                    Image("ic_check_circle_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white)
                    
                    Text("Aceptado")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 1)
                        .frame(width: 90, height: 34)
                        .foregroundColor(.gray.opacity(0.5))

                    TextField("", text: $bid)
                        .font(.body)
                        .frame(width: 90, height: 34)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .multilineTextAlignment(.center)
                        .disabled(true)
                }
                
                Spacer()
                
                HStack {
                    Image("ic_check_circle_white")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white)
                    
                    Text("Aceptado")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 10)
            .background(greenColor.opacity(0.8))
            .cornerRadius(8)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .onAppear {
            onCardShowed()
        }
    }
}
