//
//  SubCategoryCardButton.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 05/06/23.
//

import SwiftUI

struct CardServiceType: View {
    
    @State private var isPressed = false
    private let title: String
    private let imageUrl: String?
    private var action: () -> Void

    init(title: String, imageUrl: String?, action: @escaping () -> Void) {
        self.title = title
        self.imageUrl = imageUrl
        self.action = action
    }

    var body: some View {
        VStack {
            RemoteImage(urlString: imageUrl ?? "")
        }
        .frame(height: 145)
        .cornerRadius(12)
        .onTapGesture {
            action()
        }
        
        /*Button {
            isPressed = true
            withAnimation(Animation
                .linear(duration: 0.2)
                .repeatCount(0)) {
                    isPressed.toggle()
                    action?()
                }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 10)
                    .foregroundColor(isPressed ? Color.hotPink : Color.paleGreen)
                    .background(isPressed ? Color.white : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack (spacing: 8) {
                    RemoteImage(urlString: imageUrl ?? "")
                        .frame(width: 40, height: 40)

                    Text(title)
                        .font(.small)
                        .fontWeight(.w600)
                        .foregroundColor(isPressed ? .foreground : .foreground )
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                }
                .padding(.horizontal, 12)
            }
            .scaleEffect(isPressed ? 1.05 : 1.0)
        }*/
    }
}

struct SubServiceCardButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CardServiceType(title: "Button Text", imageUrl: "") {}
            .padding(.horizontal)

            CardServiceType(title: "Button Text", imageUrl: "") {}
            .padding(.horizontal)

        }

        VStack {
            CardServiceType(title: "Button Text", imageUrl: "") {}
            .padding(.horizontal)

            CardServiceType(title: "Button Text", imageUrl: "") {}
            .padding(.horizontal)

        }
        .preferredColorScheme(.dark)
    }
}
