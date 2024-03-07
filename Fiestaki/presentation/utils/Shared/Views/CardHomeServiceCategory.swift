//
//  ServiceCardButton.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 27/05/23.
//

import SwiftUI

struct CardHomeServiceCategory: View {

    @State private var isPressed = false
    private let title: String
    private let imageUrl: String?
    private var action: (() -> Void)? = nil

    init(title: String, imageUrl: String?, action: @escaping () -> Void) {
        self.title = title
        self.imageUrl = imageUrl
        self.action = action
    }

    var body: some View {
        Button {
            isPressed = true
            withAnimation(Animation
                .linear(duration: 0.2)
                .repeatCount(0)) {
                    isPressed.toggle()
                    action?()
                }
        } label: {

            ZStack {
                RoundedRectangle(cornerRadius: 23)
                    .stroke(lineWidth: 1)
                    //.foregroundColor(isPressed ? Color.iceBlue : Color.foreground )
                    .frame(height: 50)
                    //.background(isPressed ? Color.iceBlue : Color.background )
                    .clipShape(RoundedRectangle(cornerRadius: 23))

                HStack(spacing: 12) {
                    RemoteImage(urlString: imageUrl ?? "")
                        .frame(width: 30, height: 30)

                    //Spacer()
                    
                    Text(title)
                        .font(.normal)
                        .fontWeight(.w700)
                        .foregroundColor(isPressed ? .background : .foreground )
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                }
                .padding(.horizontal, 12)
            }
            .scaleEffect(isPressed ? 1.05 : 1.0)
        }
    }
}
