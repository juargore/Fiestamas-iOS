//
//  ImageGalleryView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 14/06/23.
//

import SwiftUI

struct PhotoViewerScreen: View {
    
    var gridImages: [String]
    
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    @State var isShowingImage: Bool = false
    @State var selectedImageId: String = ""

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        if isShowingImage {
            ImageGalleryView(images: gridImages,
                             isShowingImage: $isShowingImage,
                             selectedImageId: $selectedImageId)
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.iceBlue, .white]),
                    startPoint: .top,
                    endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .padding(.top, -60)

                Rectangle()
                    .foregroundColor(.white)
                    .padding(.top, -8)

                VStack {
                    header
                    Spacer()
                }
                .padding(.horizontal, 16)


                ScrollView(.vertical) {
                    ZStack {

                        VStack {
                            gridView

                        }
                        .padding(.all, 8)
                    }
                }
                .background(Color.white)
                .padding(.top, 35)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        }
    }

    private var header: some View {
        VStack {

            HStack {

                Button {
                    navigation.navigateBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.midRegular)
                        .fontWeight(.w600)
                        .foregroundColor(.hotPink)
                }
                Spacer()

                Text("Fotos")
                    .font(.normal)
                    .fontWeight(.w700)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)

                Spacer()

                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                        .padding(.top, 4)

                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.black)
                }
                .font(.regular)
            }
        }
    }

    private var gridView: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(gridImages, id: \.self) { image in

                    ZStack {

                        RemoteImage(urlString: image)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.width / 2 - 10, height: UIScreen.width / 2 - 4, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                            .padding(.all, 4)
                    }
                    .onTapGesture {
                        selectedImageId = image.id
                        isShowingImage = true
                    }
                }
            }
        }
    }
}

struct ImageGalleryView: View {
    let images: [String]

    @State private var scale: CGFloat = 1.0
    @State private var isZoomed: Bool = false
    @State private var currentIndex = 0
    @Binding var isShowingImage: Bool
    @Binding var selectedImageId: String
    @State private var orientation = UIDeviceOrientation.portrait
    @State private var screenSize = UIScreen.main.bounds.size

    var body: some View {

        GeometryReader { geometry in
            ZStack {
                TabView(selection: $selectedImageId) {
                    ForEach(images) { image in
                        ZoomableImageView(imageURL: image, scale: $scale, isZoomed: $isZoomed)
                            .tag(image.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .background(Color.black)
                .overlay(alignment: .topTrailing, content: {
                    Button {
                        isShowingImage = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.big)
                            .fontWeight(.w700)
                            .foregroundColor(.white)
                            .padding(.trailing, 32)
                            .padding(.top, 32)
                    }

                })
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .rotationEffect(rotationAngle(for: orientation))
            .frame(width: screenWidth(for: orientation), height: screenHeight(for: orientation))
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onChange(of: orientation) { newOrientation in
                updateScreenSize(for: newOrientation)
            }
            .onAppear {
                UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { _ in
                    orientation = UIDevice.current.orientation
                }
            }
            .onDisappear {
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
                NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            }
        }
    }

    private func rotationAngle(for orientation: UIDeviceOrientation) -> Angle {
        switch orientation {
        case .landscapeLeft:
            return .degrees(90)
        case .landscapeRight:
            return .degrees(-90)
        default:
            return .degrees(0)
        }
    }

    private func screenWidth(for orientation: UIDeviceOrientation) -> CGFloat {
        return orientation.isPortrait ? screenSize.width : screenSize.height
    }

    private func screenHeight(for orientation: UIDeviceOrientation) -> CGFloat {
        return orientation.isPortrait ? screenSize.height : screenSize.width
    }

    private func updateScreenSize(for orientation: UIDeviceOrientation) {
        screenSize = UIScreen.main.bounds.size
    }

}

struct ZoomableImageView: View {
    let imageURL: String
    @Binding var scale: CGFloat
    @Binding var isZoomed: Bool

    var body: some View {
        VStack {
            RemoteImage(urlString: imageURL)
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value.magnitude
                        }
                )
        }
    }
}
