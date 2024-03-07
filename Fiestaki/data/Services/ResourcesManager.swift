//
//  ResourcesManager.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 18/05/23.
//

import Foundation

public class ResourcesManager {
    /**
     Function used to read the keys and values from the `AppResources.plist`
     */
    static public func getResource(for keyType: KeyType) -> String {

        guard let path = Bundle.main.path(forResource: "Prod_Resources", ofType: "plist"),
              let xml = FileManager.default.contents(atPath: path)
        else {
            debugPrint("failed Bundle.main.path")
            return ""
        }

        guard let plistKey = try? PropertyListDecoder().decode(PlistKey.self, from: xml) else {
            debugPrint("failed plistKey")
            return ""
        }

        switch keyType {
        case .appHost:
            return plistKey.appHost
        }
    }
}

public enum KeyType {
    case appHost
}

struct PlistKey: Codable {
    var appHost: String
}
