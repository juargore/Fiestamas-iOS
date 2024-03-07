//
//  MessageRepositoryImpl.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/8/23.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import Combine

class MessageRepositoryImpl: IMessageRepository {
    
    private var firestore: Firestore
    
    init(firestore: Firestore = Firestore.firestore()) {
        //let settings = FirestoreSettings()
        //settings.isPersistenceEnabled = false
        self.firestore = firestore
        //self.firestore.settings = settings
    }
    
    private var messageApi = MessageApiImplementation()
    
    func sendChatMessage(request: NewChatMessageRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.messageApi.sendChatMessage(request: request) { result in
                switch result {
                case .success(let response):
                    debugPrint("AQUI: Success sendChatMessage")
                    promise(.success(.success(response)))
                case .failure(let error):
                    debugPrint("AQUI: Error: sendChatMessage: ", error.localizedDescription)
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getChatMessagesByServiceEvent(serviceEventId: String) -> AnyPublisher<[NotificationDb], Error> {
        let serviceCategoriesCollection = firestore.collection(Constants.messages)
        let query = serviceCategoriesCollection
            .whereField(Constants.idServiceEvent, isEqualTo: serviceEventId)
            .order(by: "timestamp")
        return serviceCategoriesCollection.collectionListenerFlow(NotificationDb.self, query)
    }
    
    func getUnreadCounterChatMessagesByServiceEvent(serviceEventId: String, senderId: String) -> AnyPublisher<Int, Error> {
        let serviceCategoriesCollection = firestore.collection(Constants.messages)
        let query = serviceCategoriesCollection
            .whereField(Constants.idServiceEvent, isEqualTo: serviceEventId)
            .whereField(Constants.isRead, isEqualTo: false)
        return serviceCategoriesCollection
            .collectionListenerFlow(NotificationDb.self, query)
            .map { notifications in
                var unreadMessages = [NotificationDb]()
                for notification in notifications {
                    if notification.id_sender == senderId {
                        unreadMessages.append(notification)
                    }
                }
                return unreadMessages.count
            }.eraseToAnyPublisher()
    }
    
    func getChatMessagesByReceiverId(receiverId: String) -> AnyPublisher<[NotificationDb], Error> {
        let serviceCategoriesCollection = firestore.collection(Constants.messages)
        let query = serviceCategoriesCollection
            .whereField(Constants.idReceiver, isEqualTo: receiverId)
            //.whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: Date.now))
            .order(by: "timestamp")
        return serviceCategoriesCollection.collectionListenerFlow(NotificationDb.self, query)
    }
    
    func getChatMessagesBySenderId(senderId: String) -> AnyPublisher<[NotificationDb], Error> {
        let serviceCategoriesCollection = firestore.collection(Constants.messages)
        let query = serviceCategoriesCollection
            .whereField(Constants.idSender, isEqualTo: senderId)
            //.whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: Date.now))
            .order(by: "timestamp")
        return serviceCategoriesCollection.collectionListenerFlow(NotificationDb.self, query)
    }
    
    func markMessagesAsRead(messages: [String]) {
        let request = MarkChatMessagesAsReadRequest(id_messages: messages)
        self.messageApi.markMessagesAsRead(request: request) { _ in }
    }
}
