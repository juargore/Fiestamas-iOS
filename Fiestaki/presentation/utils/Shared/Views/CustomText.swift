//
//  CustomText.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 08/06/23.
//

import SwiftUI

struct CustomText: View {
    var title: String
    var placeholder: String
    @State var text: String = ""

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .frame(height: 50)
                .foregroundColor(.gray.opacity(0.5))

            HStack {
                if title.isEmpty {
                    TextField(placeholder, text: $text)
                        .font(.overNormal)
                        .fontWeight(.w600)
                        .padding(.horizontal, 16)

                } else {
                    Text(title)
                        .font(.overNormal)
                        .fontWeight(.w600)
                        .padding(.horizontal, 16)
                }

                Spacer()

            }
        }
        .contentShape(Rectangle())

    }
}

struct CustomText_Previews: PreviewProvider {
    static var previews: some View {
        CustomText(title: "Text title", placeholder: "Placeholder text", text: "text")
    }
}
