//
//  InvalidInputView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 23/05/23.
//

import SwiftUI

struct InvalidInputView: View {

    var errorString: String
    var secondaryString: String = ""
    var action: (() -> Void)? = nil

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                if !errorString.isEmpty {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 10))
                        .padding(.bottom, 2)
                }
                Text(errorString)
                    .font(.small)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            Spacer()
        }
        .padding(.top, -4)
    }
}

struct InvalidInputView_Previews: PreviewProvider {
    static var previews: some View {
        InvalidInputView(errorString: "This is the error") {
            debugPrint("...")
        }
    }
}
