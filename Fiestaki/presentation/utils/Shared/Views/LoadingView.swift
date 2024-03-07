//
//  LoadingView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 26/05/23.
//

import SwiftUI

struct LoadingView: View {

    @State private var isCircleRotating = true
    private var text: String
    private var opacity: Double

    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color.hotPink, Color.hotPink.opacity(0)]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(0))

    init(text: String = "Cargando...", opacity: Double = 1.0) {
        self.text = text
        self.opacity = opacity
    }

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Image(systemName: "party.popper")
                        .font(.hugeBlack)

                    Text(text)
                        .font(.normal)
                        .fontWeight(.w800)
                        .frame(width: 110)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.foreground)
                }

                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .rotationEffect(.degrees(isCircleRotating ? 0 : 360))
                    .frame(width: 150, height: 150)
                    .onAppear() {
                        withAnimation(Animation
                            .linear(duration: 0.7)
                            .repeatForever(autoreverses: false)) {
                                self.isCircleRotating.toggle()
                            }
                    }
            }
        }
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background.opacity(opacity))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(text: "Loading...", opacity: 0.3)

        LoadingView()
            .preferredColorScheme(.dark)
            .previewDisplayName("Loading View Dark Mode")
    }
}
