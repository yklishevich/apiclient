//
//  APIRemoteError.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

/// Base class for exceptions occuring on remote system.
class APIRemoteError: APIClientError {
    let status: Int?
    
    init (status: Int?, message: String?) {
        self.status = status
        super.init(message, underlyingError: nil)
    }
    
    // MARK: `LocalizedError` protocol
    override public var errorDescription: String? {
        let errorTtl = NSLocalizedString("error", tableName: "APIClient", comment: "")
        if let status = status {
            return "\(status) \(errorTtl): \(String(describing: message))" // example: "404 error: Not Found"
        }
        else {
            return "\(errorTtl): \(String(describing: message))" // example: "error: Not Found"
        }
    }
}
