//
//  NotificationsViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation
import Combine
import Firebase

final class NotificationsViewModel: ObservableObject {
    
    private let messageUseCase = MessageUseCase()
    private let eventUseCase = EventUseCase()
    private var disposables = Set<AnyCancellable>()
    
    @Published var notificationServerList: [Notification] = []
    @Published var counterClientUnreadNotifications: Int = 0
    @Published var counterProviderUnreadNotifications: Int = 0
    
    func getMessagesNotificationsByUserId(isProvider: Bool?, userId: String?, myPartyServiceList: [MyPartyService]) {
            if isProvider != nil && userId != nil {
                messageUseCase
                    .getChatMessagesBySenderId(senderId: userId!)
                    .sink { _ in } receiveValue: { listA in
                        self.getChatMessagesByReceiverId(userId!) { listB in
                            var notificationlist = [Notification]()
                            let listDb = listA + listB
                            var uniqueSet = Set<String>()
                            let distinctList = listDb.filter {
                                uniqueSet.insert($0.id_service_event).inserted
                            }
                            distinctList.forEach { notificationDb in
                                myPartyServiceList.forEach { serviceEvent in
                                    if (notificationDb.id_service_event == serviceEvent.id) {
                                        let notification = convertNotificationDbToNotification(
                                            isProvider: isProvider!,
                                            serviceEvent: serviceEvent,
                                            notification: notificationDb
                                        )
                                        notificationlist.append(notification)
                                    }
                                }
                            }
                            
                            self.notificationServerList = notificationlist
                        }
                    }.store(in: &disposables)
            }
        }

    private func getChatMessagesByReceiverId(_ id: String, onFinish: @escaping ([NotificationDb]) -> Void) {
        messageUseCase
            .getChatMessagesByReceiverId(receiverId: id)
            .sink { _ in } receiveValue: { listB in
                onFinish(listB)
            }.store(in: &disposables)
    }
    
    private func getMyPartyService(_ idServiceEvent: String, onFinish: @escaping (MyPartyService?) -> Void) {
        eventUseCase
            .getMyPartyService(serviceEventId: idServiceEvent)
            .sink { _ in } receiveValue: { serviceEvent in
                onFinish(serviceEvent)
            }.store(in: &disposables)
    }
    
    func getCountUnreadNotificationsByClientId(clientId: String, onResult: @escaping (Int) -> Void) {
        messageUseCase
            .getChatMessagesBySenderId(senderId: clientId)
            .sink { _ in } receiveValue: { listA in
                self.getChatMessagesByReceiverId(clientId) { listB in
                    var unreadCounter = 0
                    (listA + listB).forEach { notificationDb in
                        if !notificationDb.read && clientId == notificationDb.id_receiver {
                            unreadCounter += 1
                        }
                    }
                    self.counterClientUnreadNotifications = unreadCounter
                    onResult(unreadCounter)
                }
            }.store(in: &disposables)
    }
    
    func getCountUnreadNotificationsByProviderId(providerId: String, myPartyServiceList: [MyPartyService], onResult: @escaping (Int) -> Void) {
        messageUseCase
            .getChatMessagesBySenderId(senderId: providerId)
            .sink { _ in } receiveValue: { listA in
                self.getChatMessagesByReceiverId(providerId) { listB in
                    /*var unreadCounter = 0
                    (listA + listB).forEach { notificationDb in
                        if !notificationDb.read && providerId == notificationDb.id_receiver {
                            unreadCounter += 1
                        }
                    }
                    self.counterProviderUnreadNotifications = unreadCounter*/
                    
                    var unreadCounter = 0
                    let distinctList = Array(Set(listA + listB))
                    distinctList.forEach { notificationDb in
                        myPartyServiceList.forEach { serviceEvent in
                            if (notificationDb.id_service_event == serviceEvent.id &&
                                (!notificationDb.read && providerId == notificationDb.id_receiver)
                            ) {
                                unreadCounter = unreadCounter + 1
                            }
                        }
                    }
                    
                    /*
                     var unreadCounter = 0
                                         val listDb = (listA + listB)
                                         val distinctList = listDb.distinctBy { it.id_service_event }
                                         distinctList.forEach { notificationDb ->
                                             myPartyServiceList.forEach { serviceEvent ->
                                                 if (notificationDb.id_service_event == serviceEvent?.id && (!notificationDb.read && providerId == notificationDb.id_receiver)) {
                                                     unreadCounter ++
                                                 }
                                             }
                                         }

                                         _counterProviderUnreadNotifications.value = unreadCounter
                     
                     */
                    onResult(unreadCounter)
                }
            }.store(in: &disposables)
    }
}
