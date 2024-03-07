//
//  AppStorageManager.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 23/05/23.
//

import SwiftUI

public enum StorageKeys: String {
    case appFirstLaunch = "first_launch"
    case userId = "user_id"
    case user = "user"
    case lastTokenPush = "last_token_push"
    case accountList = "account_list"
}

public protocol AppStorageManagerProtocol: AnyObject {
    func storeValue<T: Encodable>(_ value: T, for key: StorageKeys)
    func getValue<T: Decodable>(model: T.Type, for key: StorageKeys) -> T?
}

final public class AppStorageManager: AppStorageManagerProtocol {

    public init() {
        
    }
    
    func saveLoginAccountIfNeeded(data: LoginAccount) {
        let currentData = getValue(model: String.self, for: StorageKeys.accountList) ?? nil
        if let jsonData = currentData?.data(using: .utf8) {
            var listOfAccounts: [LoginAccount] = []
            do {
                listOfAccounts = try JSONDecoder().decode([LoginAccount].self, from: jsonData)
                if listOfAccounts.contains(data) {
                    debugPrint("Ya existe la cuenta, no se agrega")
                } else {
                    debugPrint("No existe la cuenta en la lista, se agrega")
                    listOfAccounts.append(data)
                    if let newData = try? JSONEncoder().encode(listOfAccounts),
                       let jsonString = String(data: newData, encoding: .utf8) {
                        storeValue(jsonString, for: StorageKeys.accountList)
                    }
                }
            } catch {
                print("Error al decodificar los datos: \(error)")
            }
        } else {
            debugPrint("No existe data, se agrega la cuenta")
            var listOfAccounts: [LoginAccount] = []
            listOfAccounts.append(data)
            if let jsonData = try? JSONEncoder().encode(listOfAccounts),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                storeValue(jsonString, for: StorageKeys.accountList)
            }
        }
    }
    
    func getStoredAccountsAsList() -> [LoginAccount] {
        let currentData = getValue(model: String.self, for: StorageKeys.accountList) ?? nil
        if let jsonData = currentData?.data(using: .utf8) {
            var listOfAccounts: [LoginAccount] = []
            do {
                listOfAccounts = try JSONDecoder().decode([LoginAccount].self, from: jsonData)
                return listOfAccounts
            } catch {
                print("Error al decodificar los datos: \(error)")
                return []
            }
        } else {
            return []
        }
    }

    public func storeValue<T: Encodable>(_ value: T, for key: StorageKeys) {
        @AppStorage(key.rawValue) var keyData: Data?

        do {
            let data = try JSONEncoder().encode(value)
            keyData = data
        } catch {
            debugPrint("AppStorageManager - Failed to encode data: ", error)
        }
    }

    public func getValue<T: Decodable>(model: T.Type, for key: StorageKeys) -> T? {
        @AppStorage(key.rawValue) var data: Data?

        guard let data = data else { return nil }

        do {
            let value = try JSONDecoder().decode(T.self, from: data)
            return value
        } catch {
            debugPrint("AppStorageManager - Failed to decode data: ", error)
        }

        return nil
    }
}
