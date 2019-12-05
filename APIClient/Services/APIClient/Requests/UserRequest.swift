//
//  UserRequest.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 11/06/2017.
//  Copyright © 2017 WPA. All rights reserved.
//

import Foundation

class UserRequest: RestAPIRequest {
    typealias EncodableAT = [String:String]
    
    var relativeURL: String { return "JSON/user.json" }
}

