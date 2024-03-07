//
//  Image+Extension.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 10/05/23.
//

import SwiftUI

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}
