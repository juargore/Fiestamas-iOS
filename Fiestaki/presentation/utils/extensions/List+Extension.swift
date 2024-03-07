//
//  List+Extension.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/24/23.
//

import Foundation
import SwiftUI

extension [MyPartyService] {
    func sortByServiceStatus(_ status: ServiceStatus) -> [MyPartyService] {
        if self.isEmpty {
            return self
        }
        
        let services = self
        
        let sortedList: [MyPartyService]
        
        switch status {
        case .Hired:
            sortedList = services.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Pending && statusB != .Pending
                }
                return false
            }.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Canceled && statusB != .Canceled
                }
                return false
            }
        case .Pending:
            sortedList = services.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Canceled && statusB != .Canceled
                }
                return false
            }.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Hired && statusB != .Hired
                }
                return false
            }
        case .Canceled:
            sortedList = services.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Hired && statusB != .Hired
                }
                return false
            }.sorted {
                if let statusA = $0.serviceStatus, let statusB = $1.serviceStatus {
                    return statusA == .Pending && statusB != .Pending
                }
                return false
            }
        default:
            sortedList = services
        }
        
        return sortedList.reversed()
    }
}

extension [MyPartyEvent] {
    func toCircleEventPerDayList() -> [CircleEventPerDay] {
        return self.map { myPartyEvent in
            CircleEventPerDay(
                time: convertStringToDateUTC(myPartyEvent.date),
                color: Color(UIColor(hex: myPartyEvent.color_hex ?? "#000000"))
            )
        }
    }
}
