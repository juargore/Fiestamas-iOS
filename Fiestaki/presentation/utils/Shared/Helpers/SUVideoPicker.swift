//
//  SUVideoPicker.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/28/23.
//

import SwiftUI
import UIKit
import MobileCoreServices // Necesario para kUTTypeMovie

struct SUVideoPickerView: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var videoURL: URL?
    @Binding var isPresented: Bool
    
    func makeCoordinator() -> VideoPickerViewCoordinator {
        return VideoPickerViewCoordinator(videoURL: $videoURL, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.mediaTypes = [kUTTypeMovie as String] // Para seleccionar solo videos
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }
}

class VideoPickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var videoURL: URL?
    @Binding var isPresented: Bool
    
    init(videoURL: Binding<URL?>, isPresented: Binding<Bool>) {
        self._videoURL = videoURL
        self._isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.videoURL = url
        }
        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
}
