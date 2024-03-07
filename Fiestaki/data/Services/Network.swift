//
//  Network.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 05/05/23.
//

import Firebase

protocol NetworkProtocol {
    func post<T: Decodable>(model: T.Type, path: String, parameters: [String: Any]?) async throws -> T 
    func getDocument<T: Decodable>(objectType: T.Type, collection: String, document: String) async throws -> T
    func getCollection<T: Decodable>(objectType: T.Type, collection: String) async throws -> [T]
    func addFirestoreListener<T: Decodable>(forCollection collectionName: String,
                                            objectType: T.Type,
                                            completion: @escaping ([T]?, Error?) -> Void) -> ListenerRegistration
    func download(from URLString: String, completion: @escaping (UIImage?) -> Void )
}

final class Network: NetworkProtocol {

    private var appHost: String
    private let cache: NSCache<NSString, UIImage>
    private let database: Firestore
    private let decoder: JSONDecoder
    private let session: URLSession

    init(appHost: String = ResourcesManager.getResource(for: .appHost),
         cache: NSCache<NSString, UIImage> = .init(),
         database: Firestore = Firestore.firestore(),
         decoder: JSONDecoder = JSONDecoder(),
         session: URLSession = URLSession.shared) {
        self.appHost = appHost
        self.cache = cache
        self.database = database
        self.decoder = decoder
        self.session = session
    }

    private func buildURL(host: String, path: String, query: String = "") -> URL? {

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path

        if !query.isEmpty {
            urlComponents.percentEncodedQuery = query
        }

        return urlComponents.url
    }

    public func post<T: Decodable>(model: T.Type, path: String, parameters: [String: Any]?) async throws -> T {

        guard let url = buildURL(host: appHost, path: path) else {
            throw NetworkError.invalidUrl(uri: path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        if let parameters {
            let body = try JSONSerialization.data(withJSONObject: parameters, options: [])
            urlRequest.httpBody = body
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidHttpResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }

        let result: T
        do {
            result = try decoder.decode(model.self, from: data)
        } catch {
            debugPrint(error)
            throw NetworkError.decodeError(model: "\(model.self)")
        }
        return result
    }

    func getDocument<T: Decodable>(objectType: T.Type, collection: String, document: String) async throws -> T {
        let documentReference = database.collection(collection).document(document)

        do {
            let documentSnapshot = try await documentReference.getDocument().data()

            guard let jsonObject = documentSnapshot else {
                throw NetworkError.invalidData
            }

            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let decodedObject = try self.decoder.decode(objectType.self, from: jsonData)
            return decodedObject
        } catch {
            debugPrint(error)
            throw NetworkError.unknownError
        }
    }

    func getCollection<T: Decodable>(objectType: T.Type, collection: String) async throws -> [T] {
        let documentReference = database.collection(collection)

        do {
            let documentsSnapshot = try await documentReference.getDocuments()
            let documents = documentsSnapshot.documents

            var objects: [T] = []
            for document in documents {
                do {
                    var jsonObject = document.data()
                    jsonObject["id"] = document.documentID
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                    let decodedObject = try self.decoder.decode(objectType.self, from: jsonData)
                    objects.append(decodedObject)
                } catch {
                    throw error
                }
            }
            return objects

        } catch {
            debugPrint(error)
            throw NetworkError.unknownError
        }
    }

    func addFirestoreListener<T: Decodable>(forCollection collectionName: String,
                                            objectType: T.Type,
                                            completion: @escaping ([T]?, Error?) -> Void) -> ListenerRegistration {

        let collectionRef = database.collection(collectionName)

        let listener = collectionRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                completion(nil, error)
                return
            }

            var objects: [T] = []

            for document in snapshot.documents {
                do {
                    var jsonObject = document.data()
                    jsonObject["id"] = document.documentID
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                    let decodedObject = try self.decoder.decode(objectType.self, from: jsonData)
                    objects.append(decodedObject)

                } catch {
                    completion(nil, error)
                    return
                }
            }

            completion(objects, nil)
        }

        return listener
    }

    func download(from URLString: String, completion: @escaping (UIImage?) -> Void ) {

        let cacheKey = NSString(string: URLString)

        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return
        }

        guard let url = URL(string: URLString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            self.cache.setObject(image, forKey: cacheKey)
            completion(image)

        }
        task.resume()
    }
}
