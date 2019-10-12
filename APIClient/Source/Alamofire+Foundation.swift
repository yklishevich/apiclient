//
//  Alamofire+Foundation.swift
//  WPA-Robertus
//
//  Created by Yauheni Klishevich on 26/09/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation
import Alamofire

//// MARK: – Base Alamofire.Request
//
//public extension Request {
//    
//    // MARK: - Object
//    
//    static func serializeReponseObjectNatively<T: Decodable>(type: T.Type,
//                                                             response: HTTPURLResponse?,
//                                                             data: Data?,
//                                                             error: Error?) -> Result<T, AFError> {
//        guard error == nil else {
//            return .failure(error!)
//        }
//        guard let validData = data, validData.count > 0 else {
//            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
//        }
//        
//        let decoder = JSONDecoder()
//        do {
//            let typedObject: T = try decoder.decode(T.self, from: validData)
//            return .success(typedObject)
//        }
//        catch let anError as DecodingError {
//            switch anError {
//            case DecodingError.dataCorrupted:
//                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//            case DecodingError.keyNotFound:
//                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//            case DecodingError.typeMismatch:
//                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//            case DecodingError.valueNotFound:
//                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//            default:
//                return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//            }
//        }
//        catch let anError {
//            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: anError)))
//        }
//    }
//}

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
/// `nil` or no data is considered an error. However, if the response is has a status code valid for empty responses
/// (`204`, `205`), then an `nil`  value is returned.
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
