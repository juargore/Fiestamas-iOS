//
//  ChatViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/10/23.
//

import Foundation
import Combine
import SwiftUI
import UIKit

final class ChatViewModel: ObservableObject {
    
    private let messageUseCase = MessageUseCase()
    private let serviceUseCase = ServiceUseCase()
    private var disposables = Set<AnyCancellable>()
    
    @Published var chatMessagesList: [Notification] = []

    func sendMessage(
        message: String,
        senderId: String,
        receiverId: String,
        serviceEventId: String,
        clientEventId: String,
        serviceId: String,
        type: String,
        onFinished: @escaping (String) -> Void
    ) {
        let request = NewChatMessageRequest(
            content: message,
            id_sender: senderId,
            id_receiver: receiverId,
            id_service_event: serviceEventId,
            id_service: serviceId,
            id_client_event: clientEventId,
            type: type
        )
        messageUseCase
            .sendChatMessage(request: request)
            .sink { completion in
                switch completion {
                case .finished:
                    onFinished("")
                case .failure(let error):
                    onFinished(error.localizedDescription)
                }
            } receiveValue: { _ in}
            .store(in: &self.disposables)
    }
    
    func getChatMessages(
        isProvider: Bool,
        serviceEvent: MyPartyService?,
        senderId: String,
        serviceEventId: String
    ) {
        messageUseCase
            .getChatMessagesByServiceEvent(serviceEventId: serviceEventId)
            .sink { _ in } receiveValue: { listDb in
                self.chatMessagesList = listDb.map {
                    convertNotificationDbToNotification(isProvider: isProvider, serviceEvent: serviceEvent, notification: $0)
                }
                
                var unreadMessagesList = [String]()
                for notification in self.chatMessagesList {
                    if notification.status == NotificationStatus.Unread && notification.idSender == senderId {
                        unreadMessagesList.append(notification.id)
                    }
                }
                self.markMessagesAsRead(messages: unreadMessagesList)
            }.store(in: &disposables)
    }
    
    private func markMessagesAsRead(messages: [String]) {
        messageUseCase.markMessagesAsRead(messages: messages)
    }
    
    func uploadMediaFilesAndSendMMS(
        image: Image,
        width: CGFloat,
        height: CGFloat,
        senderId: String,
        receiverId: String,
        serviceEventId: String,
        clientEventId: String,
        serviceId: String,
        onCompleted: @escaping (String) -> Void
    ) { 
        if let uri = getUriFromImage(image, width: width, height: height) {
            let imageAbsolutePath = uri.absoluteString
            var imageName = ""
            if let index = imageAbsolutePath.lastIndex(of: "/") {
                imageName = String(imageAbsolutePath.suffix(from: index).dropFirst())
            }
            var images = [UriFile]()
            images.append(UriFile(uri: uri, fileName: imageName))
            
            serviceUseCase
                .uploadMediaFiles(images: images, videos: nil)
                .sink { _ in } receiveValue: { response in
                    self.sendMessage(message: response.firstList.first ?? "Unknown", senderId: senderId, receiverId: receiverId, serviceEventId: serviceEventId, clientEventId: clientEventId, serviceId: serviceId, type: "IMAGE", onFinished: { msg in
                            onCompleted(msg)
                    })
                }.store(in: &self.disposables)
        } else {
            debugPrint("AQUI: No se pudo convertir la imagen a URI")
            onCompleted("No se pudo convertir la imagen a URI")
        }
    }
    
    func acceptOrDeclineQuote(
        accepted: Bool,
        serviceEventId: String,
        messageId: String,
        onFinished: @escaping (String) -> Void
    ) {
        if (accepted) {
            acceptEditQuote(serviceEventId: serviceEventId, messageId: messageId, onFinish: { onFinished($0) })
        } else {
            declineEditQuote(serviceEventId: serviceEventId, messageId: messageId, onFinish: { onFinished($0) })
        }
    }
    
    private func acceptEditQuote(serviceEventId: String, messageId: String, onFinish: @escaping (String) -> Void) {
        serviceUseCase
            .acceptEditQuoteFromClientToProvider(serviceEventId: serviceEventId, messageId: messageId)
            .sink { completion in
                switch completion {
                case .finished:
                    onFinish("")
                case .failure(let error):
                    onFinish(error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &disposables)
    }
    
    private func declineEditQuote(serviceEventId: String, messageId: String, onFinish: @escaping (String) -> Void) {
        serviceUseCase
            .declineEditQuoteFromClientToProvider(serviceEventId: serviceEventId, messageId: messageId)
            .sink { completion in
                switch completion {
                case .finished:
                    onFinish("")
                case .failure(let error):
                    onFinish(error.localizedDescription)
                }
            } receiveValue: { _ in }
            .store(in: &disposables)
    }
    
    func getIsReceived(isProvider: Bool, idReceiver: String, providerId: String, clientId: String) -> Bool {
        if isProvider {
            return providerId == idReceiver
        } else {
            return clientId != idReceiver
        }
    }
    
    func getPhoto(isReceived: Bool, senderPhoto: String, receiverPhoto: String) -> String {
        if isReceived {
            return receiverPhoto
        } else {
            return senderPhoto
        }
    }
    
    func getName(isReceived: Bool, providerName: String, clientName: String) -> String {
        if isReceived {
            return clientName
        } else {
            return providerName
        }
    }
}
