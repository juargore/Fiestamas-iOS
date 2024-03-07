//
//  IMessageRepository.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

protocol IMessageRepository {
    
    func sendChatMessage(request: NewChatMessageRequest) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func getChatMessagesByServiceEvent(serviceEventId: String) -> AnyPublisher<[NotificationDb], Error>
    
    func getUnreadCounterChatMessagesByServiceEvent(serviceEventId: String, senderId: String) -> AnyPublisher<Int, Error>
    
    func getChatMessagesByReceiverId(receiverId: String) -> AnyPublisher<[NotificationDb], Error>
    
    func getChatMessagesBySenderId(senderId: String) -> AnyPublisher<[NotificationDb], Error>
    
    func markMessagesAsRead(messages: [String])
}
