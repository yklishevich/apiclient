//
//  Alamofire+Foundation.swift
//
//  Created by Yauheni Klishevich on 26/09/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation
import Alamofire

// MARK: – Alamofire.DataRequest

public extension DataRequest {
    
    // MARK: - Object
    
    @discardableResult
    func responseObject<T: Decodable>(_ type: T.Type,
                                      queue: DispatchQueue = .main,
                                      completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return response(queue: queue,
                        responseSerializer: ResponseDecoder<T>(),
                        completionHandler: completionHandler)
    }
}

/// A `ResponseSerializer` that decodes the response data using `JSONDecoder`. By default, a request returning
/// `nil` or no data is considered an error. However, if the response has a status code valid for empty responses
/// (`204`, `205`), then `nil`  value is returned.
public final class ResponseDecoder<T>: ResponseSerializer where T: Decodable {
    public let dataPreprocessor: DataPreprocessor
    
    /// Creates an instance with the provided values.
    ///
    /// - Parameters:
    ///   - dataPreprocessor:    `DataPreprocessor` used to prepare the received `Data` for serialization.
    public init(dataPreprocessor: DataPreprocessor = ResponseDecoder.defaultDataPreprocessor) {
        self.dataPreprocessor = dataPreprocessor
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else {
            throw error!
        }
        
        guard var data = data, !data.isEmpty else {
           throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
        }
        
        data = try dataPreprocessor.preprocess(data)
        
        do {
            let typedResponse = try JSONDecoder().decode(T.self, from: data)
            return typedResponse
        } catch {
            throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
        }
    }
}
