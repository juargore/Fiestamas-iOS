//
//  NetworkError.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 05/05/23.
//

import Foundation

public enum NetworkError: Error {
    case invalidUrl(uri: String)
    case invalidHttpResponse
    case fetchDocumentError
    case unauthorized
    case unknownError
    case invalidData
    case invalidStatusCode(statusCode: Int)
    case decodeError(model: String)
    case encodeError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidUrl(uri: _):
            return NSLocalizedString("The URL is invalid", comment: "")
        case .invalidHttpResponse:
            return  NSLocalizedString("Http response is invalid", comment: "")
        case .fetchDocumentError:
            return NSLocalizedString("Error getting document", comment: "")
        case .unauthorized:
            return NSLocalizedString("You are unauthorized", comment: "")
        case .unknownError:
            return NSLocalizedString("An unknown error has occured", comment: "")
        case .invalidData:
            return NSLocalizedString("Data received is invalid", comment: "")
        case .invalidStatusCode(statusCode: let statusCode):
            return NSLocalizedString("Invalid HTTP status code \(statusCode) ", comment: "")
        case .decodeError(model: _):
            return NSLocalizedString("Failed to decode", comment: "")
        case .encodeError:
            return NSLocalizedString("Failed to encode", comment: "")
        }
    }
}
