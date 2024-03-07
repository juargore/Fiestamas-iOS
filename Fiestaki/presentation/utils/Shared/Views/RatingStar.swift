//
//  RatingStar.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/24/23.
//

import SwiftUI

struct RatingStar: View {
    
    var rating: Int
    var size: CGFloat = 10
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<(rating), id: \.self) { _ in
                Image(systemName: "star.fill")
                    //.font(.moreTiny)
                    .font(.system(size: size))
                    .foregroundColor(.hotPink)
                    .padding(.vertical, 0.5)
            }
        }
    }
}

struct RatingStar_Previews: PreviewProvider {
    static var previews: some View {
        RatingStar(rating: 4)
    }
}
