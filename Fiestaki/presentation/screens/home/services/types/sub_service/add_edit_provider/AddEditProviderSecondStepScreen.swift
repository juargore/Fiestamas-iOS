//
//  AddEditProviderSecondStepScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/27/23.
//

import SwiftUI

struct AddEditProviderSecondStepScreen: View {
    
    @ObservedObject var servicesViewModel = ServicesViewModel()
    @ObservedObject var detailsViewModel = DetailsServiceViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var isEditing: Bool
    var screenInfo: ScreenInfo
    var images: [String]
    var videos: [String]
    var serviceProviderData: ServiceProviderData
    
    @State var service: Service? = nil
    @State var user: FirebaseUserDb? = nil
    
    @State var shouldPresentImagePicker = false
    @State var shouldPresentActionSheet = false
    @State var shouldPresentCamera = false
    @State var shouldPresentVideoPicker = false
    @State var tempPhoto: Image? = nil
    @State var tempPhotoWidth: CGFloat = 0.0
    @State var tempPhotoHeight: CGFloat = 0.0
    
    @State var tempVideo: URL?
    
    @State var imageList: [UriFile] = []
    @State var videoList: [UriFile] = []
    
    @State var showToast = false
    @State var messageToast = ""
    
    init(
        isEditing: Bool,
        screenInfo: ScreenInfo,
        images: [String],
        videos: [String],
        serviceProviderData: ServiceProviderData
    ) {
        self.isEditing = isEditing
        self.screenInfo = screenInfo
        self.images = images
        self.videos = videos
        self.serviceProviderData = serviceProviderData
        
    }
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            
            VStack {
                if isEditing {
                    
                }
                servicesHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    title: screenInfo.event?.name ?? "Servicio",
                    subTitle: detailsViewModel.getLikedStrings(screenInfo: screenInfo),
                    smallSubtitle: true,
                    showSubTitle: isEditing ? false : true
                ) {
                    navigation.navigateBack()
                }
                
                VStack {
                    VStack {
                        Text(isEditing ? "Editar Servicio" : "Alta de Servicio")
                            .foregroundColor(Color.hotPink)
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Text(serviceProviderData.name)
                            .foregroundColor(Color.black)
                            .font(.system(size: 16))
                        
                        Divider()
                        
                        HStack {
                            Image("ic_camera")
                                .resizable()
                                .frame(width: 22, height: 22)
                            
                            Text("Fotos")
                                .font(.headline)
                                .foregroundColor(Color.hotPink)
                            
                            Spacer()
                        }
                        
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color.white)
                                            
                                            Image("ic_add_fiestaki")
                                                .resizable()
                                                .frame(width: 46, height: 46)
                                        }
                                        .onTapGesture {
                                            self.shouldPresentActionSheet = true
                                        }
                                        
                                        Text("Agregar")
                                            .foregroundColor(Color.ashGray)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    LazyHStack {
                                        ForEach(imageList, id: \.self) { item in
                                            CardPhotoOrVideo(uriFile: item, onItemClick: { uri in
                                                imageList.removeAll { $0 == uri }
                                            })
                                        }
                                    }
                                }
                            }
                            .frame(height: 120)
                        }
                        
                        
                        Divider()
                        
                        HStack {
                            Image("ic_play")
                                .resizable()
                                .frame(width: 22, height: 22)
                            
                            Text("Videos")
                                .font(.headline)
                                .foregroundColor(Color.hotPink)
                            
                            Spacer()
                        }
                        
                        HStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(Color.white)
                                            
                                            Image("ic_add_fiestaki")
                                                .resizable()
                                                .frame(width: 46, height: 46)
                                        }
                                        .onTapGesture {
                                            self.shouldPresentVideoPicker = true
                                        }
                                        
                                        Text("Agregar")
                                            .foregroundColor(Color.ashGray)
                                            .font(.subheadline)
                                    }
                                    .padding(.horizontal, 10)
                                    
                                    LazyHStack {
                                        ForEach(videoList, id: \.self) { item in
                                            CardPhotoOrVideo(uriFile: item, isVideo: true, onItemClick: { uri in
                                                videoList.removeAll { $0 == uri }
                                            })
                                        }
                                    }
                                }
                            }
                            .frame(height: 120)
                        }
                        
                        
                        FiestakiButton(text: "Finalizar") {
                            if imageList.isEmpty {
                                messageToast = "Agregue al menos una foto antes de finalizar"
                                showToast = true
                            } else {
                                // showProgressDialog = true
                                servicesViewModel.uploadMediaFilesIfNecessary(
                                    images: imageList,
                                    videos: videoList,
                                    isEditing: isEditing,
                                    onFilesUploaded: { imageLinks, videoLinks in
                                        if isEditing {
                                            let requestToUpdate = UpdateServiceProviderRequest(
                                                name: serviceProviderData.name,
                                                description: serviceProviderData.description,
                                                min_attendees: Int(serviceProviderData.minCapacity) ?? 1,
                                                max_attendees: Int(serviceProviderData.maxCapacity) ?? 2,
                                                price: serviceProviderData.cost,
                                                images: imageLinks,
                                                videos: videoLinks,
                                                unit: serviceProviderData.unit.toUnit(),
                                                address: serviceProviderData.addressData?.address ?? "",
                                                lat: serviceProviderData.addressData?.latitude ?? "",
                                                lng: serviceProviderData.addressData?.longitude ?? ""
                                            )
                                            if service?.id != nil {
                                                servicesViewModel.updateServiceForProvider(
                                                    serviceId: service!.id!,
                                                    request: requestToUpdate,
                                                    onFinished: { success in
                                                        if success {
                                                            messageToast = "Servicio actualizado correctamente!"
                                                            showToast = true
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                                // delay of 1 second
                                                                navigation.navigateToRoot()
                                                            }
                                                        } else {
                                                            messageToast = "Error al actualizar el Servicio. Revise los Logs"
                                                            showToast = true
                                                        }
                                                    }
                                                )
                                            } else {
                                                messageToast = "El ID del servicio es nil :("
                                                showToast = true
                                            }
                                        } else {
                                            let serviceCategoryId = screenInfo.serviceCategory?.id ?? ""
                                            let subServiceTypeId = screenInfo.subService?.id ?? ""
                                            let serviceTypeId = screenInfo.serviceType?.id ?? ""
                                            let requestToCreate = AddServiceProviderRequest(
                                                id_service_category: serviceCategoryId,
                                                id_service_type: serviceTypeId,
                                                id_sub_service_type: subServiceTypeId,
                                                id_provider: user?.id ?? "",
                                                provider_name: user?.business_name ?? "",
                                                name: serviceProviderData.name,
                                                description: serviceProviderData.description,
                                                icon: "",
                                                image: imageLinks.first ?? "",
                                                rating: 5,
                                                min_attendees: Int(serviceProviderData.minCapacity) ?? 1,
                                                max_attendees: Int(serviceProviderData.maxCapacity) ?? 2,
                                                price: serviceProviderData.cost,
                                                attributes: serviceProviderData.attributes,
                                                images: imageLinks,
                                                videos: videoLinks,
                                                unit: serviceProviderData.unit.toUnit(),
                                                address: serviceProviderData.addressData?.address ?? "",
                                                lat: serviceProviderData.addressData?.latitude ?? "",
                                                lng: serviceProviderData.addressData?.longitude ?? ""
                                            )
                                            servicesViewModel.createServiceForProvider(
                                                request: requestToCreate,
                                                onFinished: { success in
                                                    if success {
                                                        messageToast = "Servicio creado correctamente!"
                                                        showToast = true
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                            // delay of 1 second
                                                            navigation.navigateToRoot()
                                                        }
                                                    } else {
                                                        messageToast = "Error al crear el Servicio. Revise los Logs"
                                                        showToast = true
                                                    }
                                                }
                                            )
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding(16)
                }
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.7), radius: 5)
                .background(Color.lavenderMist)
                .padding(12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.hotPink)
                        .shadow(color: .gray.opacity(0.7), radius: 5)
                        .padding(12)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
            if screenInfo.service?.id != nil {
                detailsViewModel.getServiceDetails(serviceId: screenInfo.service!.id!, onFinished: { service in
                    self.service = service
                })
            }
            images.forEach { image in
                let uriFile = image.toUri()
                if uriFile != nil {
                    self.imageList.append(uriFile!)
                }
            }
            
            videos.forEach { video in
                let uriFile = video.toUri()
                if uriFile != nil {
                    self.videoList.append(uriFile!)
                }
            }
        }
        .onChange(of: self.tempPhoto) { newPhoto in
            if newPhoto != nil {
                let uri: URL? = getUriFromImage(newPhoto!, width: tempPhotoWidth, height: tempPhotoHeight)
                if uri != nil {
                    let imageAbsolutePath = uri!.absoluteString
                    var imageName = ""
                    if let index = imageAbsolutePath.lastIndex(of: "/") {
                        imageName = String(imageAbsolutePath.suffix(from: index).dropFirst())
                    }
                    imageList.append(UriFile(uri: uri!, fileName: imageName))
                }
            }
        }
        .onChange(of: self.tempVideo) { uri in
            if uri != nil {
                let videoAbsolutePath = uri!.absoluteString
                var videoName = ""
                if let index = videoAbsolutePath.lastIndex(of: "/") {
                    videoName = String(videoAbsolutePath.suffix(from: index).dropFirst())
                }
                videoList.append(UriFile(uri: uri!, fileName: videoName))
            } else {
                debugPrint("AQUI: newPhoto is nil")
            }
        }
        .sheet(isPresented: $shouldPresentImagePicker) {
            SUImagePickerView(
                sourceType: self.shouldPresentCamera ? .camera : .photoLibrary,
                image: self.$tempPhoto,
                isPresented: self.$shouldPresentImagePicker,
                imageWidth: self.$tempPhotoWidth,
                imageHeight: self.$tempPhotoHeight
            )
        }.actionSheet(isPresented: $shouldPresentActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text(""),
                buttons: [ActionSheet.Button.default(Text("Cámara fotográfica"),
                action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = true
                }), ActionSheet.Button.default(Text("Galería de imágenes"), action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = false
                }), ActionSheet.Button.cancel()]
            )
        }
        .sheet(isPresented: $shouldPresentVideoPicker) {
            SUVideoPickerView(videoURL: self.$tempVideo, isPresented: self.$shouldPresentVideoPicker)
                .edgesIgnoringSafeArea(.all)
        }
    }
}


struct CardPhotoOrVideo: View {
    
    var uriFile: UriFile
    var isVideo: Bool = false
    var onItemClick: (UriFile) -> Void
    
    var body: some View {
        ZStack {
            
            if isVideo {
                Image("ic_video_movie")
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 110)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fill)
            } else {
                RemoteImage(urlString: uriFile.uri.absoluteString)
                    .frame(maxWidth: 100, maxHeight: 110)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fill)
            }
            
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Eliminar")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .foregroundColor(.black)
                    Image("ic_trash_can")
                        .resizable()
                        .frame(width: 10, height: 12)
                    Spacer()
                }
                .background(Color.white)
                .onTapGesture {
                    onItemClick(uriFile)
                }
            }
            .frame(maxWidth: 100, maxHeight: 110)
        }
    }
}
