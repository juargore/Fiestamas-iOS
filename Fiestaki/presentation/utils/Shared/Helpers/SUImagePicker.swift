//
//  SUImagePicker.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/20/23.
//

import SwiftUI
import UIKit

struct SUImagePickerView: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var image: Image?
    @Binding var isPresented: Bool
    @Binding var imageWidth: CGFloat
    @Binding var imageHeight: CGFloat
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(
            image: $image,
            isPresented: $isPresented,
            imageWidth: $imageWidth,
            imageHeight: $imageHeight
        )
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }

}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var image: Image?
    @Binding var isPresented: Bool
    @Binding var imageWidth: CGFloat
    @Binding var imageHeight: CGFloat
    
    init(
        image: Binding<Image?>,
        isPresented: Binding<Bool>,
        imageWidth: Binding<CGFloat>,
        imageHeight: Binding<CGFloat>
    ) {
        self._image = image
        self._isPresented = isPresented
        self._imageWidth = imageWidth
        self._imageHeight = imageHeight
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let width = image.size.width
            let height = image.size.height
            
            print("Ancho de la imagen seleccionada: \(width)")
            print("Altura de la imagen seleccionada: \(height)")
            
            self.imageWidth = width
            self.imageHeight = height
            self.image = Image(uiImage: image)
        }
        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }    
}
