//
//  APITransportError.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 11/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

/// Error is used to report any problems at transport level. When this type of error occurs usually there is no
/// response from server (containing http status and some body)
/// Examples of transport errors:
///     - timeout error
///     - incompatible protocol version
class APITransportError: APIClientError {
 
    // MARK: `LocalizedError` protocol
    override public var errorDescription: String? {
        return underlyingError?.localizedDescription
    }
    
}
