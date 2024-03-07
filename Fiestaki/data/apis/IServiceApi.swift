//
//  IServiceApi.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

protocol IServiceApi {
    
    func likeService(userId: String, serviceId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func createService(request: AddServiceProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func updateService(idService: String, request: UpdateServiceProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func deleteService(serviceId: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func enableOrDisableService(idService: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func createNewClassicQuote(idServiceEvent: String, completion: @escaping (Result<CreateQuoteResponse, Error>) -> Void)
    func createNewExpressQuote(idServiceEvent: String, request: ItemsExpressQuoteRequest, completion: @escaping (Result<CreateQuoteResponse, Error>) -> Void)
    func addItemsToExistingQuote(idServiceEvent: String, idQuotation: String, request: ItemsQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func deleteItemsFromExistingQuote(idServiceEvent: String, idQuotation: String, index: Int, completion: @escaping (Result<Bool, Error>) -> Void)
    func createNewOffer(idServiceEvent: String, idQuotation: String, request: ItemBidOfferRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func acceptOffer(idServiceEvent: String, idQuotation: String, request: ItemBidAcceptedRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func updateServiceStatus(idServiceEvent: String, request: ItemUpdateStatusRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func addNotesToExistingQuote(idServiceEvent: String, idQuotation: String, request: ItemAddNotesToQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func updateExpressQuote(idServiceEvent: String, idQuotation: String, request: ItemAddNotesToQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void)
    func requestQuotation(idServiceEvent: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func requestEditQuote(idServiceEvent: String, idQuotation: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func approveRequestEditQuote(idServiceEvent: String, idQuotation: String, idMessage: String, completion: @escaping (Result<Bool, Error>) -> Void)
    func declineRequestEditQuote(idServiceEvent: String, idQuotation: String, idMessage: String, completion: @escaping (Result<Bool, Error>) -> Void)

}

class ServiceApiImplementation: IServiceApi {
    //let baseUrl = "https://us-central1-fiestaki-1.cloudfunctions.net/app/api/v1/"
    
    func likeService(userId: String, serviceId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "user/\(userId)/like-service/\(serviceId)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func createService(request: AddServiceProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service")!
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
    
    func updateService(idService: String, request: UpdateServiceProviderRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service/\(idService)")!
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
    
    func deleteService(serviceId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service/\(serviceId)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func enableOrDisableService(idService: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service/\(idService)/status")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func createNewClassicQuote(idServiceEvent: String, completion: @escaping (Result<CreateQuoteResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                if let response = try? JSONDecoder().decode(CreateQuoteResponse.self, from: data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "ServiceApi", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create classic quote"])))
                }
            } else {
                completion(.failure(NSError(domain: "ServiceApi", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create classic quote"])))
            }
        }.resume()
    }
    
    func createNewExpressQuote(idServiceEvent: String, request: ItemsExpressQuoteRequest, completion: @escaping (Result<CreateQuoteResponse, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try? JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                if let response = try? JSONDecoder().decode(CreateQuoteResponse.self, from: data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "ServiceApi", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create express quote"])))
                }
            } else {
                completion(.failure(NSError(domain: "ServiceApi", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create express quote"])))
            }
        }.resume()
    }
    
    private func createMultipartBody(with data: Data, boundary: String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"media.jpg\"\r\n")
        body.appendString("Content-Type: image/jpeg\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func addItemsToExistingQuote(idServiceEvent: String, idQuotation: String, request: ItemsQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/element")!
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
        
        func deleteItemsFromExistingQuote(idServiceEvent: String, idQuotation: String, index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/element/\(index)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(true))
            }.resume()
        }
        
        func createNewOffer(idServiceEvent: String, idQuotation: String, request: ItemBidOfferRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/bid")!
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
        
        func acceptOffer(idServiceEvent: String, idQuotation: String, request: ItemBidAcceptedRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/bid")!
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
        
        func updateServiceStatus(idServiceEvent: String, request: ItemUpdateStatusRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)")!
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
    
    func addNotesToExistingQuote(idServiceEvent: String, idQuotation: String, request: ItemAddNotesToQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)")!
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
        
        func updateExpressQuote(idServiceEvent: String, idQuotation: String, request: ItemAddNotesToQuoteRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)")!
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
        
        func requestQuotation(idServiceEvent: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(true))
            }.resume()
        }
        
        func requestEditQuote(idServiceEvent: String, idQuotation: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/approval")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(true))
            }.resume()
        }
        
        func approveRequestEditQuote(idServiceEvent: String, idQuotation: String, idMessage: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/approval/\(idMessage)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(true))
            }.resume()
        }
        
        func declineRequestEditQuote(idServiceEvent: String, idQuotation: String, idMessage: String, completion: @escaping (Result<Bool, Error>) -> Void) {
            let url = URL(string: Constants.baseUrl + "service_event/\(idServiceEvent)/quotation/\(idQuotation)/decline/\(idMessage)")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(true))
            }.resume()
        }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
