//
//  IAuthApi.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

protocol IAuthApi {
    func createUserOnServer(userRequest: UserRequest, completion: @escaping (Result<FirebaseUserDb, Error>) -> Void)
    func createProviderOnServer(providerRequest: ProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func subscribeTokenPushNotifications(subscribeRequest: SubscribeRequest)
    func unsubscribeTokenPushNotifications(subscribeRequest: SubscribeRequest)
    func updateTokenPushNotifications(updateRequest: UpdateRequest)
    func updateProviderOnServer(
        id_user: String, providerRequestEdit: ProviderRequestEdit, completion: @escaping (Result<Bool, Error>) -> Void
    )
    func updateClientOnServer(id_user: String, userRequestEdit: UserRequestEdit, completion: @escaping (Result<Bool, Error>) -> Void)
}

class AuthApiImplementation: IAuthApi {
    //let baseUrl = "https://us-central1-fiestaki-1.cloudfunctions.net/app/api/v1/"
    
    func createUserOnServer(userRequest: UserRequest, completion: @escaping (Result<FirebaseUserDb, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(userRequest)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(FirebaseUserDb.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func createProviderOnServer(providerRequest: ProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let jsonToSend = try? JSONEncoder().encode(providerRequest)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func subscribeTokenPushNotifications(subscribeRequest: SubscribeRequest) {
        let url = URL(string: Constants.baseUrl + "push-notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let jsonToSend = try? JSONEncoder().encode(subscribeRequest)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                //completion(.failure(error))
                return
            }
            //completion(.success(true))
        }.resume()
    }
    
    func unsubscribeTokenPushNotifications(subscribeRequest: SubscribeRequest) {
        let url = URL(string: Constants.baseUrl + "push-notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let jsonToSend = try? JSONEncoder().encode(subscribeRequest)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                //completion(.failure(error))
                return
            }
            //completion(.success(true))
        }.resume()
    }
    
    func updateTokenPushNotifications(updateRequest: UpdateRequest) {
        let url = URL(string: Constants.baseUrl + "push-notifications")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let jsonToSend = try? JSONEncoder().encode(updateRequest)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                //completion(.failure(error))
                return
            }
            //completion(.success(true))
        }.resume()
    }
    
    func updateProviderOnServer(
        id_user: String,
        providerRequestEdit: ProviderRequestEdit,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        let url = URL(string: Constants.baseUrl + "user/\(id_user)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let jsonToSend = try? JSONEncoder().encode(providerRequestEdit)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func updateClientOnServer(id_user: String, userRequestEdit: UserRequestEdit, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "user/\(id_user)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let jsonToSend = try? JSONEncoder().encode(userRequestEdit)
        debugPrint(String(data: jsonToSend!, encoding: .utf8)!)
        request.httpBody = jsonToSend
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }.resume()
    }
}
