//
//  NewQuoteOrEditDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct NewQuoteOrEditDialog: View {
    
    var isEditingData: Bool
    var quote: GetQuoteResponse?
    var editableList: [QuoteProductsInformation]?
    var onSendNewQuoteClicked: (
        [QuoteProductsInformation], /// items
        String, /// notes
        Int /// total
    ) -> Void
    var onEditQuoteClicked: (
        [QuoteProductsInformation], /// newItems
        Int, /// oldSizeItems
        String, /// providerNotes
        String, /// personalNotesClient
        String, /// personalNotesProvider
        Int /// total
    ) -> Void
    var onDismiss: () -> Void
    
    @State private var title: String
    @State private var originalItemsSize: Int
    @State private var importantNotes: String
    @State private var showQuoteChildDialog = false
    @State private var items: [QuoteProductsInformation] = []
    @State private var total: Double
    
    init(
        isEditingData: Bool,
        quote: GetQuoteResponse?,
        editableList: [QuoteProductsInformation]?,
        onSendNewQuoteClicked: @escaping ([QuoteProductsInformation], String, Int) -> Void,
        onEditQuoteClicked: @escaping ([QuoteProductsInformation], Int, String, String, String, Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.isEditingData = isEditingData
        self.quote = quote
        self.editableList = editableList
        self.onSendNewQuoteClicked = onSendNewQuoteClicked
        self.onEditQuoteClicked = onEditQuoteClicked
        self.onDismiss = onDismiss
        
        originalItemsSize = quote?.elements.count ?? 0
        importantNotes = quote?.notes ?? ""
        var subtotal = 0.0
        editableList?.forEach { item in
            subtotal += Double(item.subtotal) ?? 0.0
        }
        total = subtotal
        title = "Nueva Cotización"
        if isEditingData {
            title = "Editar Cotización"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .foregroundColor(.black)
            }.onTapGesture {
                onDismiss()
            }
            
            Text(title)
                .fontWeight(.semibold)
                .font(.system(size: 19))
                .foregroundColor(.black)
            
            Divider()
            
            VStack {
                CardProductInformation(
                    item: QuoteProductsInformation(
                        quantity: "Cant.",
                        description: "Descripción",
                        price: "Precio",
                        subtotal: "Subtotal"
                    ),
                    isTitle: true,
                    addRemoveButton: true
                )
                LazyVStack {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        CardProductInformation(
                            item: item,
                            isTitle: false,
                            addRemoveButton: true,
                            onRemoveClicked: { it in
                                items.remove(at: index)
                                
                                var nSubtotal = 0.0
                                items.forEach { item in
                                    nSubtotal += Double(item.subtotal) ?? 0.0
                                }
                                total = nSubtotal
                            }
                        )
                    }
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Image("ic_add_fiestaki")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .onTapGesture {
                            showQuoteChildDialog = true
                        }
                        .padding(.horizontal, 16)
                }
                
                
            }.frame(height: 130)
            
            Divider()
                .padding(.bottom, 12)
            
            HStack {
                Text("Notas importantes")
                    .font(.caption)
                    .foregroundColor(.black)
                Spacer()
                Text("Total    ")
                    .font(.caption)
                    .foregroundColor(.black)
                Text("$ \(String(total))")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            HStack {
                TextField("", text: $importantNotes, axis: .vertical)
                    .font(.body)
                    .lineLimit(5, reservesSpace: true)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .foregroundColor(.black)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.ashGray, lineWidth: 0.8))
                Spacer()
                VStack {
                    Spacer()
                    FiestakiButton(text: "Enviar", customCorner: 15, action: {
                        if !items.isEmpty {
                            if isEditingData {
                                onEditQuoteClicked(
                                    items,
                                    originalItemsSize,
                                    importantNotes,
                                    quote?.noteBook_client ?? "",
                                    quote?.noteBook_provider ?? "",
                                    Int(total)
                                )
                            } else {
                                onSendNewQuoteClicked(
                                    items,
                                    importantNotes,
                                    Int(total)
                                )
                            }
                        }
                    })
                }
                .frame(height: 110)
            }
            .padding(.bottom, 10)
        }.padding(10)
        .popUpDialog(isShowing: $showQuoteChildDialog, padding: 0, dialogContent: {
            ChildQuoteDialog(
                onSaved: { qty, desc, price in
                    let quantity = Double(qty) ?? 0.0
                    let cost = Double(price) ?? 0.0
                    let subtotal = String(quantity * cost)
                    
                    items.append(QuoteProductsInformation(quantity: qty, description: desc, price: price, subtotal: subtotal))
                    
                    var nSubtotal = 0.0
                    items.forEach { item in
                        nSubtotal += Double(item.subtotal) ?? 0.0
                    }
                    total = nSubtotal
                    showQuoteChildDialog = false
                },
                onDismiss: {
                    showQuoteChildDialog = false
                }
            )
        })
    }
}


struct ChildQuoteDialog : View {
    
    var onSaved: (
        String, /// quantity
        String, /// description
        String /// price
    ) -> Void
    
    var onDismiss: () -> Void
    
    @State var quantity = ""
    @State var description = ""
    @State var price = ""
    
    @State var showToast = false
    @State var messageToast = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .foregroundColor(.black)
            }.onTapGesture {
                onDismiss()
            }
            
            Text("Nuevo Producto")
                .fontWeight(.semibold)
                .font(.system(size: 19))
                .foregroundColor(.black)
            
            Divider()
                .padding(.vertical, 12)
            
            CustomTextField(placeholder: "Cantidad", text: $quantity)
                .frame(height: 50)
                .padding(.vertical, 4)
            
            CustomTextField(placeholder: "Descripción", text: $description)
                .frame(height: 50)
                .padding(.vertical, 4)
            
            CustomTextField(placeholder: "Precio", text: $price)
                .frame(height: 50)
                .padding(.vertical, 4)
            
            FiestakiButton(text: "Guardar", action: {
                if quantity.isEmpty {
                    messageToast = "El campo 'Cantidad' no puede estar vacío"
                    showToast = true
                    return
                }
                
                if description.isEmpty {
                    messageToast = "El campo 'Descripción' no puede estar vacío"
                    showToast = true
                    return
                }
                
                if price.isEmpty {
                    messageToast = "El campo 'Precio' no puede estar vacío"
                    showToast = true
                    return
                }
                
                onSaved(quantity, description, price)
            })
        }
        .padding()
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
    }
}
