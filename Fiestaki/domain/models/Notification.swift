//
//  Notification.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct Notification: Codable, Hashable {
    let id: String
    var status: NotificationStatus?
    var icon: String?
    var eventName: String?
    var eventType: String?
    var festejadosName: String?
    var serviceName: String?
    let message: String
    let clientName: String
    let providerName: String
    let idReceiver: String
    let idSender: String
    let date: String?
    let clientEventId: String
    let receiverId: String
    let senderId: String
    let receiverPhoto: String
    let senderPhoto: String
    let serviceId: String
    let serviceEventId: String
    let serviceEvent: MyPartyService?
    let isApproved: Bool?
    let type: MessageType

    /*init(id: String, status: NotificationStatus? = nil, icon: String? = nil, eventName: String? = nil, eventType: String? = nil, festejadosName: String? = nil, serviceName: String? = nil, message: String, clientName: String, providerName: String, idReceiver: String, idSender: String, date: String? = nil, clientEventId: String, receiverId: String, senderId: String, receiverPhoto: String, senderPhoto: String, serviceId: String, serviceEventId: String, serviceEvent: MyPartyService? = nil, isApproved: Bool? = nil, type: MessageType
    ) {
        self.id = id
        self.status = status
        self.icon = icon
        self.eventName = eventName
        self.eventType = eventType
        self.festejadosName = festejadosName
        self.serviceName = serviceName
        self.message = message
        self.clientName = clientName
        self.providerName = providerName
        self.idReceiver = idReceiver
        self.idSender = idSender
        self.date = date
        self.clientEventId = clientEventId
        self.receiverId = receiverId
        self.senderId = senderId
        self.receiverPhoto = receiverPhoto
        self.senderPhoto = senderPhoto
        self.serviceId = serviceId
        self.serviceEventId = serviceEventId
        self.serviceEvent = serviceEvent
        self.isApproved = isApproved
        self.type = type
    }*/
}

enum NotificationStatus: String, Codable {
    case All
    case Read
    case Unread
}

struct BottomNotificationStatus: Codable {
    let status: NotificationStatus
    let name: String

    init(status: NotificationStatus, name: String) {
        self.status = status
        self.name = name
    }
}
