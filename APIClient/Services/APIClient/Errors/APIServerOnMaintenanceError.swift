//
//  APIServerOnMaintenanceError.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

class APIServerOnMaintenanceError: APIRemoteError {
    
    init (_ message: String) {
        super.init(status: nil, message: message)
    }
    
}
