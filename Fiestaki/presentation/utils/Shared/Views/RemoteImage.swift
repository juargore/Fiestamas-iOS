//
//  RemoteImage.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 08/05/23.
//

import SwiftUI

struct RemoteImage: View {
    
    @StateObject var imageLoader = ImageLoader()
    
    let urlString: String

    var body: some View {
        RemoteImageBody(image: imageLoader.image)
            .onAppear {
                imageLoader.load(from: urlString)
            }
    }
}

final class ImageLoader: ObservableObject {

    @Published var image: Image? = nil
    private let network: NetworkProtocol

    init(network: NetworkProtocol = Network()) {
        self.network = network
    }

    func load(from urlString: String) {
        network.download(from: urlString) { uiImage in
            guard let uiImage = uiImage else { return }

            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
            }
        }
    }
}

struct RemoteImageBody: View {
    
    var image: Image?

    var body: some View {
        if let image = image {
                image
                    .resizable()
                    //.aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    //.frame(width: 0, height: 0)
            }
        
        /*
        image?
            .resizable()
            //.aspectRatio(contentMode: .fit)
    
        ??
        
        Image(systemName: "photo.fill")
            .resizable()
            //.aspectRatio(contentMode: .fit)
        */
    }
}
