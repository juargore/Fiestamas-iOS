//
//  ChatScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/11/23.
//

import SwiftUI

struct ChatScreen: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    @ObservedObject var chatViewModel = ChatViewModel()
    @EnvironmentObject var navigation: ServicesByEventsNavGraph
    
    var user: FirebaseUserDb? = nil
    var myPartyService: MyPartyService
    var clientId: String
    var providerId: String
    var serviceEventId: String
    var serviceId: String
    var isProvider: Bool
    var clientEventId: String
    var eventName: String
    
    @State private var image: Image? = nil
    @State private var imageWidth: CGFloat = 0.0
    @State private var imageHeight: CGFloat = 0.0
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionSheet = false
    @State private var shouldPresentCamera = false
    @State private var showProgressDialog = false
    
    @State private var showToast = false
    @State private var messageToast = ""
    
    init(user: FirebaseUserDb? = nil, myPartyService: MyPartyService, clientId: String, providerId: String, serviceEventId: String, serviceId: String, isProvider: Bool, clientEventId: String, eventName: String) {
        self.user = user
        self.myPartyService = myPartyService
        self.clientId = clientId
        self.providerId = providerId
        self.serviceEventId = serviceEventId
        self.serviceId = serviceId
        self.isProvider = isProvider
        self.clientEventId = clientEventId
        self.eventName = eventName
        
        var senderId = providerId
        if isProvider {
            senderId = clientId
        }
        chatViewModel.getChatMessages(
            isProvider: isProvider,
            serviceEvent: myPartyService,
            senderId: senderId,
            serviceEventId: serviceEventId
        )
    }
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                mainHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    showBackButton: true,
                    onBackButtonClicked: {
                        navigation.navigateBack()
                    }
                )
                
                VStack {
                    HStack {
                        RemoteImage(urlString: myPartyService.image ?? "")
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.ashGray, lineWidth: 0.2))
                            .padding(8)
                        VStack(alignment: HorizontalAlignment.leading) {
                            Text(eventName)
                                .font(.medium)
                                .foregroundColor(.black)
                            Text(myPartyService.name ?? "")
                                .font(.normal)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .background(Color(UIColor(hex: "#F1F2F2")))
                    .padding(.horizontal, 6)
                    
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)
                    
                    VStack {
                        ScrollViewReader { scrollView in
                            ScrollView(.vertical) {
                                LazyVStack {
                                    ForEach(chatViewModel.chatMessagesList, id: \.self) { chat in
                                        let isReceived = chatViewModel.getIsReceived(isProvider: isProvider, idReceiver: chat.idReceiver, providerId: providerId, clientId: clientId)
                                        let photo = chatViewModel.getPhoto(isReceived: isReceived, senderPhoto: chat.senderPhoto, receiverPhoto: chat.receiverPhoto)
                                        let name = chatViewModel.getName(isReceived: isReceived, providerName: chat.providerName, clientName: chat.clientName)
                                        
                                        if chat.type == MessageType.APPROVAL && !isProvider && chat.isApproved == Optional(false) {
                                            CardChatApproval(
                                                vm: chatViewModel,
                                                text: chat.message,
                                                serviceEventId: myPartyService.id ?? "",
                                                messageId: chat.id
                                            )
                                        } else {
                                            ChatCard(date: chat.date ?? "", photo: photo, name: name, message: chat.message, isReceived: isReceived, type: chat.type)
                                        }
                                    }
                                }
                                .id("ChatScrollView")
                                .background(Color.white)
                                .padding(10)
                            }
                            .onChange(of: chatViewModel.chatMessagesList) { _ in
                                scrollView.scrollTo("ChatScrollView", anchor: .bottom)
                            }
                        }
                        
                        Spacer()
                    }
                    .background(Color.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 2)
                    .padding(.top, 6)
                    
                    FooterHeaderToSendMessage(
                        onSendTextMessage: { message in
                            var senderId = clientId
                            var receiverId = providerId
                            if isProvider {
                                senderId = providerId
                                receiverId = clientId
                            }
                            
                            chatViewModel.sendMessage(
                                message: message,
                                senderId: senderId,
                                receiverId: receiverId,
                                serviceEventId: serviceEventId,
                                clientEventId: clientEventId,
                                serviceId: serviceId,
                                type: "MESSAGE",
                                onFinished: { msg in
                                    // do nothing -> message sent
                                }
                            )
                        },
                        showImageBottomSheet: {
                            self.shouldPresentActionSheet = true
                        }
                    )
                }
                .background(Color(UIColor(hex: "#F0F3F4")))
                .cornerRadius(14)
                .padding()
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: image) { newImage in
            if newImage != nil {
                showProgressDialog = true
                var senderId = clientId
                if isProvider {
                    senderId = providerId
                }
                var receiverId = providerId
                if isProvider {
                    receiverId = clientId
                }
                
                chatViewModel.uploadMediaFilesAndSendMMS(image: newImage!, width: imageWidth, height: imageHeight, senderId: senderId, receiverId: receiverId, serviceEventId: serviceEventId, clientEventId: clientEventId, serviceId: serviceId, onCompleted: { msg in
                    image = nil
                    if !msg.isEmpty {
                        messageToast = msg
                        showToast = true
                    }
                    showProgressDialog = false
                })
            }
        }
        .sheet(isPresented: $shouldPresentImagePicker) {
                SUImagePickerView(
                    sourceType: self.shouldPresentCamera ? .camera : .photoLibrary,
                    image: self.$image,
                    isPresented: self.$shouldPresentImagePicker,
                    imageWidth: self.$imageWidth,
                    imageHeight: self.$imageHeight
                )}
        .actionSheet(isPresented: $shouldPresentActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Envíar imagen vía"),
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
        .popUpDialog(isShowing: $showProgressDialog, dialogContent: {
            ProgressDialog(isVisible: showProgressDialog, message: "Enviando mensaje...")
        })
    }
    
    
    struct ChatCard: View {
        var date: String
        var photo: String
        var name: String
        var message: String
        var isReceived: Bool
        var type: MessageType
        
        var body: some View {
            if type == .NOTIFICATION || type == .APPROVAL {
                CardChatNotification(text: message)
            }
            if type == .IMAGE || type == .MESSAGE {
                if isReceived {
                    CardChatReceivedMessage(date: date, photo: photo, name: name, message: message, type: type)
                } else {
                    CardChatSentMessage(date: date, photo: photo, name: name, message: message, type: type)
                }
            }
        }
    }
    
    struct CardChatApproval: View {
        
        var vm: ChatViewModel
        var text: String
        var serviceEventId: String
        var messageId: String
        
        var body: some View {
            VStack {
                VStack {
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text("Aceptar")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(Color.white)
                        }
                        .background(Color.hotPink)
                        .cornerRadius(8)
                        .onTapGesture {
                            vm.acceptOrDeclineQuote(
                                 accepted: true,
                                 serviceEventId: serviceEventId,
                                 messageId: messageId,
                                 onFinished: { message in
                                     
                                 }
                            )
                        }
                        
                        VStack {
                            Text("Declinar")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .foregroundColor(Color.white)
                        }
                        .background(Color.ashGray)
                        .cornerRadius(8)
                        .onTapGesture {
                            vm.acceptOrDeclineQuote(
                                 accepted: false,
                                 serviceEventId: serviceEventId,
                                 messageId: messageId,
                                 onFinished: { message in
                                     
                                 }
                            )
                        }
                        
                        Spacer()
                    }
                }
                .padding(10)
            }
            .background(Color(UIColor(hex: "#F0F3F4s")))
            .cornerRadius(8)
            .padding(10)
        }
    }
    
    struct CardChatNotification: View {
        var text: String
        
        var body: some View {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.orange)
                Text(text)
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.pink, lineWidth: 0.5)
                .background(Color.white)
            )
        }
    }
    
    struct CardChatReceivedMessage: View {
        var date: String
        var photo: String
        var name: String
        var message: String
        var type: MessageType
        
        var body: some View {
            HStack {
                if photo.isEmpty {
                    CircleAvatarWithInitials(name: name, size: 36, color: Color(UIColor(hex: "#C3E5EC")))
                } else {
                    RemoteImage(urlString: photo)
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                }
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.small)
                        .foregroundColor(.black)
                    BodyMessageForImageAndText(text: message, sent: false, type: type)
                }
            }
        }
    }
    
    struct CardChatSentMessage: View {
     var date: String
     var photo: String
     var name: String
     var message: String
     var type: MessageType
        var body: some View {
            HStack {
                VStack(alignment: .trailing) {
                    Text(name)
                        .font(.small)
                        .foregroundColor(.black)
                    BodyMessageForImageAndText(text: message, sent: true, type: type)
                }
                if photo.isEmpty {
                    CircleAvatarWithInitials(name: name, size: 36, color: Color(UIColor(hex: "#F1F2F2")))
                } else {
                    RemoteImage(urlString: photo)
                        .frame(width: 36, height: 36)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                }
            }
        }
     }
    
    struct BodyMessageForImageAndText: View {
        var text: String
        var sent: Bool
        var type: MessageType
        
        var body: some View {
            HStack {
                if type == .MESSAGE {
                    if sent {
                        Spacer()
                    }
                    Text(text)
                        .padding(sent ? .trailing : .leading, 5)
                        .foregroundColor(.hotPink)
                        .font(.normal)
                    if !sent {
                        Spacer()
                    }
                }
                
                if type == .IMAGE {
                    HStack {
                        if sent {
                            Spacer()
                        }
                        //let _ = debugPrint("AQUI: Recibe image on chat: ", text)
                        RemoteImage(urlString: text)
                            .frame(width: 180, height: 120)
                            .cornerRadius(16)
                            .scaledToFill()
                            
                        if !sent {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    struct FooterHeaderToSendMessage: View {
        
        @State private var message: String = ""
        var onSendTextMessage: (String) -> Void
        var showImageBottomSheet: () -> Void
        
        var body: some View {
            VStack(spacing: 10) {
                HStack {
                    // Attachments section
                    Button(action: {
                        showImageBottomSheet()
                    }) {
                        Image("ic_clip")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(13)
                            .background(Color(UIColor(hex: "#ECF0F1")))
                            .clipShape(Circle())
                    }
                    
                    Spacer().frame(width: 3)
                    
                    // Input text for message section
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 50)
                            .foregroundColor(Color.white)
                        
                        CustomTextField(placeholder: "", text: $message)
                    }
                    
                    Spacer().frame(width: 8)
                    
                    // Button send section
                    Button(action: {
                        if !message.isEmpty {
                            onSendTextMessage(message)
                            message = ""
                        }
                    }) {
                        Image("ic_send_chat")
                            .resizable()
                            .padding(10)
                            .background(Color.hotPink)
                            .foregroundColor(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(width: 50, height: 55)
                    
                }
                .frame(height: 70)
            }
            .padding(.horizontal)
            .background(Color(UIColor(hex: "#F1F2F2")))
        }
    }
}

struct CircleAvatarWithInitials: View {
    let name: String
    let size: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .padding(5)
            
            if !name.isEmpty {
                let initials = extractInitials(name)
                TextInCircle(text: initials)
            }
        }
    }
}

struct TextInCircle: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundColor(.black)
    }
}

func extractInitials(_ name: String) -> String {
    let names = name.split(separator: " ")
    switch names.count {
    case 0:
        return ""
    case 1:
        return names[0].prefix(2).uppercased()
    default:
        return "\(names[0].prefix(1).uppercased())\(names[1].prefix(1).uppercased())"
    }
}
