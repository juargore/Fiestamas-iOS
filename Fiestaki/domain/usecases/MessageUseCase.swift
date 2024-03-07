//
//  MessageUseCase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

class MessageUseCase {
    
    private let messageRepository = MessageRepositoryImpl()
    
    func sendChatMessage(request: NewChatMessageRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return messageRepository.sendChatMessage(request: request)
    }
    
    func getChatMessagesByServiceEvent(serviceEventId: String) -> AnyPublisher<[NotificationDb], Error> {
        return messageRepository.getChatMessagesByServiceEvent(serviceEventId: serviceEventId)
    }
    
    func getUnreadCounterChatMessagesByServiceEvent(serviceEventId: String, senderId: String) -> AnyPublisher<Int, Error> {
        return messageRepository.getUnreadCounterChatMessagesByServiceEvent(serviceEventId: serviceEventId, senderId: senderId)
    }
    
    func getChatMessagesByReceiverId(receiverId: String) -> AnyPublisher<[NotificationDb], Error> {
        return messageRepository.getChatMessagesByReceiverId(receiverId: receiverId)
    }
    
    func getChatMessagesBySenderId(senderId: String) -> AnyPublisher<[NotificationDb], Error> {
            return messageRepository.getChatMessagesBySenderId(senderId: senderId)
        }
    
    func markMessagesAsRead(messages: [String]) {
        messageRepository.markMessagesAsRead(messages: messages)
    }
}
