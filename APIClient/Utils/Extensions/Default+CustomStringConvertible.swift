//
//  Default+CustomStringConvertible.swift
//  Networking
//
//  Created by Yauheni Klishevich on 16/09/2019.
//  Copyright © 2019 YKL. All rights reserved.
//

import Foundation

/**
 Implementation was borrowed from https://medium.com/@YogevSitton/use-auto-describing-objects-with-customstringconvertible-49528b55f446
 */
extension CustomStringConvertible {
    var description : String {
        var description: String = ""
        // Warning is bug: https://bugs.swift.org/browse/SR-7394
        if self is AnyObject {
            let address = Unmanaged.passUnretained(self as AnyObject).toOpaque()
            description = "<\(type(of: self)): \(address)>"
        }
        else {
            description = "<\(type(of: self))>"
        }
        let selfMirror = Mirror(reflecting: self)
        for (index, child) in selfMirror.children.enumerated() {
            if index == 0 {
                description += "{"
            }
            if let propertyName = child.label {
                description += "\(propertyName): \(child.value)"
                if (index != selfMirror.children.count - 1) {
                    description += ", "
                }
                else {
                    description += "}"
                }
            }
        }
        return description
    }
}
