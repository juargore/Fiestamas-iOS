//
//  SuccessDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/23/23.
//

import Foundation
import SwiftUI

struct SuccessDialog: View {
    
    var serviceType: String
    var serviceName: String
    var contactName: String
    var image: String
    var phone: String
    var email: String
    var whatsapp: String
    var onPhoneClicked: () -> Void
    var onEmailClicked: () -> Void
    var onWhatsappClicked: () -> Void
    var onOkClicked: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image("ic_check_green")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Text("Haz agregado un nuevo servicio de \(serviceType) a tu bandeja")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
            }
            
            Divider()
                .padding(.vertical, 10)
            
            HStack {
                RemoteImage(urlString: image)
                    .frame(width: 80, height: 100)
                    .padding(.horizontal, 10)
                
                VStack {
                    HStack {
                        Text(serviceName)
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Contacto: ")
                            .foregroundColor(Color.hotPink)
                            .font(.subheadline)
                        
                        Text(contactName)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            
            VStack {
                HStack {
                    VStack {
                        ButtonSuccessDialogOption(text: phone) {
                            onPhoneClicked()
                        }
                    }
                    .frame(width: .infinity)
                    .padding(.trailing, 5)
                    
                    VStack {
                        ButtonSuccessDialogOption(text: whatsapp) {
                            onWhatsappClicked()
                        }
                    }
                    .frame(width: .infinity)
                    .padding(.leading, 5)
        
                }
                .frame(width: .infinity)
                
                HStack {
                    VStack {
                        ButtonSuccessDialogOption(text: email) {
                            onEmailClicked()
                        }
                    }
                    .frame(width: .infinity)
                    .padding(.trailing, 5)
                    
                    VStack {
                        ButtonSuccessDialogOption(text: "OK") {
                            onOkClicked()
                        }
                    }
                    .frame(width: .infinity)
                    .padding(.leading, 5)
                }
                .frame(width: .infinity)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            
        }
        .padding(12)
    }
}

struct ButtonSuccessDialogOption: View {
    
    var text: String
    var onClicked: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(text)
                .font(.footnote)
                .foregroundColor(Color.white)
                .padding(.vertical, 10)
            
            Spacer()
        }
        .background(Color.hotPink)
        .cornerRadius(16)
        .onTapGesture {
            onClicked()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessDialog(
            serviceType: "Terraza",
            serviceName: "La Fuente Rosa",
            contactName: "Octavio López",
            image: "",
            phone: "123 4567 6789",
            email: "Mensaje",
            whatsapp: "Whatsapp",
            onPhoneClicked: { },
            onEmailClicked: { },
            onWhatsappClicked: { },
            onOkClicked: { }
        )
    }
}
