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
open class APIClientError: LocalizedError, CustomStringConvertible {
    public let message: String?
    public let underlyingError: Error?
    
    public init(_ message: String?, underlyingError: Error?) {
        self.message = message
        self.underlyingError = underlyingError
    }
    
    public convenience init(_ message: String) {
        self.init(message, underlyingError: nil)
    }
    
    public convenience init(underlyingError: Error) {
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
            description += "\("error".localized): \(underlyingError)"
        }
        description += ")"
        return description
    }
}

extension APIClientError {
    
    static func apiErrorFrom(_ error: Error) -> APIClientError {
        var retError: APIClientError
        
        switch error {
        case let afError as AFError:
            switch afError {
            case .sessionTaskFailed(let error):
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorTimedOut {
                    retError = APITimeoutError(nsError.localizedDescription, underlyingError: error)
                }
                else {
                    // AFError can add additional text to message of underlying error in it's localizedDescription,
                    // so we pass error.localizedDescription as message
                    // For example in case of "Domain=NSURLErrorDomain Code=-1009 "De internetverbinding is offline."
                    // AFError.localizedDescription returns "URLSessionTask failed with error: De internetverbinding is offline."
                    retError = APIClientError(error.localizedDescription, underlyingError: afError)
                }
            case .responseValidationFailed(let responseValidationFailureReason):
                switch responseValidationFailureReason {
                case AFError.ResponseValidationFailureReason.customValidationFailed(let underlyingError)
                    where underlyingError is APIClientError:
                    retError = underlyingError as! APIClientError
                default:
                    assert(false, "Unknown error")
                    retError = APIClientError(underlyingError: afError)
                }
            default:
                retError = APIClientError("Unknown error", underlyingError: afError)
            }
        case let theError as NSError where theError.domain == NSURLErrorDomain:
            retError = APITransportError(underlyingError: theError)
        default:
            retError = APIClientError("Unknown error", underlyingError: error)
        }
        return retError
    }
}

extension String {
    var localized: String {
        let bundle: Bundle
        if let path = Bundle(for: APIClient.self).path(forResource: "APIClientResources", ofType: "bundle") {
            bundle = Bundle(path: path)!
        }
        else {
            bundle = Bundle.main
        }
        return NSLocalizedString(self, tableName: "APIClient", bundle: bundle, comment: "")
    }
}
