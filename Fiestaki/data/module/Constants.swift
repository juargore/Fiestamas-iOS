//
//  Constants.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct Constants {
    static let baseUrl = "https://us-central1-fiestaki-1.cloudfunctions.net/app/api/v1/"
    
    // Collections
    static let attributes = "attributes"
    static let eventTypes = "event_types"
    static let serviceCategories = "service_categories"
    static let serviceTypes = "service_types"
    static let services = "services"
    static let subServiceTypes = "sub_service_types"
    static let users = "users"
    static let clientEvents = "client_events"
    static let servicesEvent = "services_event"
    static let quotations = "quotations"
    static let messages = "messages"

    // Fields
    static let idServiceCategory = "id_service_category"
    static let idServiceType = "id_service_type"
    static let idSubServiceType = "id_sub_service_type"
    static let idClientEvent = "id_client_event"
    static let idServiceEvent = "id_service_event"
    static let eventsTypes = "events_types"
    static let idClient = "id_client"
    static let idProvider = "id_provider"
    static let isDeleted = "is_deleted"
    static let idReceiver = "id_receiver"
    static let idSender = "id_sender"
    static let idService = "id_service"
    static let isRead = "read"

    // Shared Preferences Values
    static let sharedPrefsName = "password_preferences"
    static let fieldPassword = "password_data"
    static let fieldFirstTime = "first_time_app_running"
}
