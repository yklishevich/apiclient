//
//  User.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 11/06/2017.
//  Copyright © 2017 WPA. All rights reserved.
//

import Foundation

final class User: CustomStringConvertible {
    var id: Int = 0
    var externalId:String = ""
    var username: String = ""
}

extension User: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case externalId = "external_id"
        case username
    }
}


