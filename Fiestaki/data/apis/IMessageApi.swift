//
//  IMessageApi.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

protocol IMessageApi {
    func sendChatMessage(request: NewChatMessageRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func markMessagesAsRead(request: MarkChatMessagesAsReadRequest, completion: @escaping (Result<Bool, Error>) -> Void)
}

class MessageApiImplementation: IMessageApi {
    //let baseUrl = "https://us-central1-fiestaki-1.cloudfunctions.net/app/api/v1/"
    
    func sendChatMessage(request: NewChatMessageRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "message")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func markMessagesAsRead(request: MarkChatMessagesAsReadRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "message/read")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = try? JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
}
