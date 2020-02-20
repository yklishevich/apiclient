//
//  APIRemoteError.swift
//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

/// Base class for exceptions occuring on remote system.
open class APIRemoteError: APIClientError {
    let status: Int?
    
    public init (status: Int?, message: String?) {
        self.status = status
        super.init(message, underlyingError: nil)
    }
    
    // MARK: `LocalizedError` protocol
    override open var errorDescription: String? {
        if let status = status {
            return "\(status) \("error".localized): \(String(describing: message))" // example: "404 error: Not Found"
        }
        else {
            return "\("error".localized): \(String(describing: message))" // example: "error: Not Found"
        }
    }
}
