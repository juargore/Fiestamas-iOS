//
//  Endpoints.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 18/05/23.
//

import Foundation

extension Network {

    public enum Endpoints {
        case userLogin
        case userCreate

        public var value: String {
            switch self {

            case .userLogin:
                return "/app/api/v1/user/login"
            case .userCreate:
                return "/app/api/v1/user"
            }
        }
    }
}


