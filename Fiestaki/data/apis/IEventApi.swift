//
//  IEventApi.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

protocol IEventApi {
    func createNewEvent(eventRequest: CreateEventRequest, completion: @escaping (Result<CreateEventResponse, Error>) -> Void)
    func addServiceToExistingEvent(eventId: String, serviceId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class EventApiImplementation: IEventApi {
    //let baseUrl = "https://us-central1-fiestaki-1.cloudfunctions.net/app/api/v1/"

    func createNewEvent(eventRequest: CreateEventRequest, completion: @escaping (Result<CreateEventResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "client_event")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(eventRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let eventResponse = try JSONDecoder().decode(CreateEventResponse.self, from: data)
                    completion(.success(eventResponse))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func addServiceToExistingEvent(eventId: String, serviceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service_event/\(eventId)/?id_service=\(serviceId)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { _, _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }.resume()
        }
    }
