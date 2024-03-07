//
//  FiestakiButton.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 27/05/23.
//

import SwiftUI

struct FiestakiButton: View {

    @State private var isPressed = false
    
    var text: String
    var customCorner: CGFloat
    var action: (() -> Void)? = nil

    init(text: String, customCorner: CGFloat = 25, action: @escaping () -> Void) {
        self.text = text
        self.customCorner = customCorner
        self.action = action
    }

    var body: some View {
        Button {
        } label: {
            Text(text)
                .padding(.horizontal, 40)
                .font(.overNormal)
                .fontWeight(.w700)
                .foregroundColor(.background)
                .frame(height: 50)
                .background(isPressed ? .foreground : Color.hotPink)
                .cornerRadius(customCorner)
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .pressEvents {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                } onRelease: {
                    withAnimation {
                        isPressed = false
                    }
                    action?()
                }
        }
        
    }
}

struct ButtonPress: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(ButtonPress(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

struct FiestakiButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FiestakiButton(text: "Button Text") {}
            .padding(.horizontal)

            FiestakiButton(text: "Button Text") {}
            .padding(.horizontal)

        }

        VStack {
            FiestakiButton(text: "Button Text") {}
            .padding(.horizontal)

            FiestakiButton(text: "Button Text") {}
            .padding(.horizontal)

        }
        .preferredColorScheme(.dark)
    }
}
