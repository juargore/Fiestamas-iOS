//
//  ChatAndNotificationsCards.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation

enum MessageType: Codable, Hashable {
    case MESSAGE
    case NOTIFICATION
    case APPROVAL
    case IMAGE
    case VIDEO
    case URL
}

func fromString(_ stringValue: String?) -> MessageType {
        guard let unwrappedString = stringValue?.uppercased() else {
            return .MESSAGE
        }

        switch unwrappedString {
            case "NOTIFICATION":
                return .NOTIFICATION
            case "APPROVAL":
                return .APPROVAL
            case "IMAGE":
                return .IMAGE
            case "VIDEO":
                return .VIDEO
            case "URL":
                return .URL
            default:
                return .MESSAGE
        }
    }
