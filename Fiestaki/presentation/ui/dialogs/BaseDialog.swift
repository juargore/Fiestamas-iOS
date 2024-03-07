//
//  BaseDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/19/23.
//

import SwiftUI

struct CustomDialog<DialogContent: View>: ViewModifier {
  @Binding var isShowing: Bool
    let padding: CGFloat
  let dialogContent: DialogContent

  init(
    isShowing: Binding<Bool>,
    padding: CGFloat,
    @ViewBuilder dialogContent: () -> DialogContent
  ) {
    _isShowing = isShowing
      self.padding = padding
     self.dialogContent = dialogContent()
  }

  func body(content: Content) -> some View {
   // wrap the view being modified in a ZStack and render dialog on top of it
    ZStack {
      content
      if isShowing {
        // the semi-transparent overlay
          Rectangle().foregroundColor(Color.black.opacity(0.6)).edgesIgnoringSafeArea(.all)
        // the dialog content is in a ZStack to pad it from the edges
        // of the screen
        ZStack {
          dialogContent
            .background(
              RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.white))
        }.padding(padding)
      }
    }
  }
}

extension View {
    func popUpDialog<DialogContent: View>(
        isShowing: Binding<Bool>,
        padding: CGFloat = 15,
        @ViewBuilder dialogContent: @escaping () -> DialogContent
    ) -> some View {
        self.modifier(
            CustomDialog(
                isShowing: isShowing,
                padding: padding,
                dialogContent: { AnyView(dialogContent()) }
            )
        )
    }
}
