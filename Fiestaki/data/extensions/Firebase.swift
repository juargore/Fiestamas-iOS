//
//  Firebase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import FirebaseCore
import FirebaseFirestore
import Firebase
import Combine
import FirebaseFirestoreSwift

extension DocumentReference {
    func documentListenerFlow<T: FirebaseModel>(_ type: T.Type) -> AnyPublisher<T?, Error> {
        let subject = PassthroughSubject<T?, Error>()
        self.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                do {
                    if var data = documentSnapshot.data() {
                        data = convertTimestampsToDates(in: data)
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        var decodedObject: T = try JSONDecoder().decode(T.self, from: jsonData)
                        decodedObject.id = documentSnapshot.documentID
                        subject.send(decodedObject)
                    } else {
                        subject.send(nil)
                    }
                } catch {
                    subject.send(completion: .failure(error))
                }
            } else {
                subject.send(nil)
            }
        }

        return subject.eraseToAnyPublisher()
    }
}

extension CollectionReference {
    func collectionListenerFlow<T: FirebaseModel>(_ type: T.Type, _ query: Query? = nil) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()

        let listener = query?.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                var dataList = [T]()
                querySnapshot?.documents.forEach { documentSnapshot in
                    if documentSnapshot.exists {
                        do {
                            var data = documentSnapshot.data()
                            data = convertTimestampsToDates(in: data)
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            var decodedObject: T = try JSONDecoder().decode(T.self, from: jsonData)
                            decodedObject.id = documentSnapshot.documentID
                            dataList.append(decodedObject)
                        } catch {
                            subject.send(completion: .failure(error))
                        }
                    }
                }
                subject.send(dataList)
            }
        }
        
        _ = query != nil ? listener : self.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                subject.send(completion: .failure(error))
            } else {
                var dataList = [T]()
                querySnapshot?.documents.forEach { documentSnapshot in
                    if documentSnapshot.exists {
                        do {
                            var data = documentSnapshot.data()
                            data = convertTimestampsToDates(in: data)
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            var decodedObject: T = try JSONDecoder().decode(T.self, from: jsonData)
                            decodedObject.id = documentSnapshot.documentID
                            dataList.append(decodedObject)
                        } catch {
                            subject.send(completion: .failure(error))
                        }
                    } else {
                        subject.send([])
                    }
                }
                subject.send(dataList)
            }
        }

        return subject.eraseToAnyPublisher()
    }
}

func convertTimestampsToDates(in dictionary: [String: Any]) -> [String: Any] {
    var convertedDictionary = dictionary
    for (key, value) in dictionary {
        if let timestamp = value as? Timestamp {
            let date = dateToString(timestamp.dateValue())
            convertedDictionary[key] = date
        } else if let nestedDictionary = value as? [String: Any] {
            let convertedNestedDictionary = convertTimestampsToDates(in: nestedDictionary)
            convertedDictionary[key] = convertedNestedDictionary
        }
    }
    return convertedDictionary
}

func dateToString(_ date: Date) -> String {
    let dateFormatter = ISO8601DateFormatter()
    return dateFormatter.string(from: date)
}
