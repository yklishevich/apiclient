//
//  APIRemoteError.swift
//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

/**
 Runtime exceptions represent problems that are the result of a programming problem, and as such, the API client code
 cannot reasonably be expected to recover from them or to handle them in any way. Such problems include arithmetic
 exceptions, such as dividing by zero; pointer exceptions, such as trying to access an object through a null reference;
 and indexing exceptions, such as attempting to access an array element through an index that is too large or too small.
 
 In context of APIClient runtime errors are used for errors that are not expected to be handled by APIClint's client
 and that should crash the app. For example deserialization errors are treated as runtime errors.
 */
open class APIRuntimeError: APIClientError {

}
