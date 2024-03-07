//
//  BaseResult.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

enum BaseResult<T, U> {
    case success(T)
    case error(U)
}

// Ejemplo de uso:
/*let successResult: BaseResult<String, Int> = .success("Datos exitosos")
let errorResult: BaseResult<String, Int> = .error(404)

switch successResult {
case .success(let data):
    print("Éxito: \(data)")
case .error(let rawResponse):
    print("Error: \(rawResponse)")
}*/
