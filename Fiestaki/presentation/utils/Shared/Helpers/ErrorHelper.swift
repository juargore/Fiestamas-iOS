//
//  ErrorHelper.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 15/05/23.
//

import Foundation
import FirebaseAuth

class ErrorHelper {
    static func localize(error: NSError) -> String {
        print(error)
        if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
            case .weakPassword:
                return "Contraseña debil"
            case .invalidEmail:
                return "Correo inválido"
            case .emailAlreadyInUse:
                return "Correo ya está en uso"
            case .userNotFound:
                return "Usuario no existe"
            case .wrongPassword:
                return "Contraseña inválida"
            case .tooManyRequests:
                return "Muchos intentos fallidos"
            default:
                return "Ha ocurrido un error"
            }
        }
        return "Ha ocurrido un error"
    }
}
