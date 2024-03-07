//
//  CustomAlertView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 30/05/23.
//

import SwiftUI

struct CustomAlertView : View {
    @Binding var isShowing: Bool
    let title: String
    let message: String
    let buttonText: String
    let buttonAction: (() -> Void)?

    var body: some View {
        if isShowing{
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.hotPink)
                        .font(.enormous)
                        .padding(.vertical, 10)

                    Text(title)
                        .font(.headline)

                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.vertical, 10)

                    Button {
                        withAnimation {
                            isShowing.toggle()
                            buttonAction?()
                        }
                    } label: {
                        Text(buttonText)
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                }
                .padding(.all, 24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(radius: 10)
            }
            .animation(.easeInOut, value: isShowing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CustomAlertView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAlertView(isShowing: .constant(true), title: "Title", message: "message", buttonText: "Ok") {}
    }
}
