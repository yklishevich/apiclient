//
//  APIUnauthorizedError.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

class APIIncompatibleAppVersionError: APITransportError {
    let appVersion: String
    let minRequiredVersion: String
    
    init(appVersion: String, minRequiredVersion: String) {
        self.appVersion = appVersion
        self.minRequiredVersion = minRequiredVersion
        super.init(nil, underlyingError: nil)
    }
    
    // MARK: `LocalizedError` protocol
    override public var errorDescription: String? {
        return "Server requires \(minRequiredVersion) min app version. Current version is \(appVersion)"
    }
    
}
