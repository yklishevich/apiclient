//
//  APIClientError.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 11/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation
import Alamofire


/// Base class for errors being returned by APIClient
/// We do not use enum for errors as enum doesn't allow of extending the module (adding new types of errors).
/// This is required when we want to plug in this module as external via some kind of dependency manager.
public class APIClientError: LocalizedError, CustomStringConvertible {
    let message: String?
    let underlyingError: Error?
    
    init(_ message: String?, underlyingError: Error?) {
        self.message = message
        self.underlyingError = underlyingError
    }
    
    convenience init(_ message: String) {
        self.init(message, underlyingError: nil)
    }
    
    convenience init(underlyingError: Error) {
        self.init(nil, underlyingError: underlyingError)
    }
    
    // MARK: `LocalizedError` protocol
    public var errorDescription: String? {
        if let message = message {
            return message
        }
        else if let underlyingError = underlyingError {
            return underlyingError.localizedDescription
        }
        else {
            return description
        }
    }
    
    // MARK: `CustomStringConvertible` protocol
    public var description: String {
        var description = "\(type(of: self))("
        if let message = message, !message.isEmpty {
            description += "message: \(message)"
            if underlyingError != nil {
                description += " ,"
            }
        }
        if let underlyingError = underlyingError {
            let errorTtl = NSLocalizedString("error", tableName: "APIClient", comment: "")
            description += "\(errorTtl): \(underlyingError)"
        }
        description += ")"
        return description
    }
}

extension APIClientError {
    
    public class func apiErrorFrom(_ error: Error) -> APIClientError {
        var anError: APIClientError
        
        switch error {
        case let afError as AFError:
            switch afError {
            case .responseValidationFailed(let responseValidationFailureReason):
                switch responseValidationFailureReason {
                case AFError.ResponseValidationFailureReason.customValidationFailed(let underlyingError)
                    where underlyingError is APIClientError:
                    return underlyingError as! APIClientError
                default:
                    assert(false, "Unknown error")
                    return APIClientError(underlyingError: afError)
                }
            case .responseSerializationFailed(_):
                return APIRuntimeError(underlyingError: afError)
            default:
                anError = APIClientError("Unknown error", underlyingError: afError)
            }
        case let theError as NSError where theError.domain == NSURLErrorDomain:
            anError = APITransportError(underlyingError: theError)
        default:
            anError = APIClientError("Unknown error", underlyingError: error)
        }
        return anError
    }
}
