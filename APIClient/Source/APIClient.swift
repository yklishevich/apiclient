import UIKit
import Alamofire
import Reachability


public protocol APIClientDelegate: class {
    
    /// This method allows to interprete some responses from server as error.
    /// Returned error will be returned in Result.failure to code that invokes APIClient.sendRequest(apiRequest:)
    /// - Parameters:
    ///   - urlResponse
    ///   - data            Data received in body.
    /// - Returns:          The created `APIClientError` or `nil`.
    func apiClient(_ apiClient: APIClient, urlResponse: HTTPURLResponse, data: Data?) -> APIClientError?
}


public class APIClient: NSObject {
    
    /// Before using this property singleton must be initialized using `initShared(baseURL:)` static function.
    public static let shared: APIClient = {
        precondition(APIClient.baseUrlForSharedClient != nil,
                     "Singleton must be initialize using `initShared(baseURL:)`")
        
        let configuration = URLSessionConfiguration.default // alamofire does not support background configuration
        configuration.httpAdditionalHeaders = ["Accept" : "application/json",
                                               "Content-Type" : "application/json"]
        
        //        #if DEBUG
        //            configuration.timeoutIntervalForRequest = 0.001 // 0 value leads to default 60 value.
        //        #else
        configuration.timeoutIntervalForRequest = 30 // seconds
        //        #endif
        configuration.timeoutIntervalForResource = 120.0
        let sessionManager = Session(configuration: configuration)
        
        // http://stackoverflow.com/questions/24030814/swift-language-nsclassfromstring/24524077#24524077
        guard let apiClientClassName = ProcessInfo.processInfo.environment["APIClientClassName"],
            let apiClientClass = NSClassFromString(apiClientClassName) as? APIClient.Type
            else {
                return APIClient(baseURL: APIClient.baseUrlForSharedClient, manager: sessionManager)
        }
        
        return apiClientClass.init(baseURL: APIClient.baseUrlForSharedClient, manager: sessionManager)
    }()
    
    public static func initShared(baseURL: URL) throws {
        if APIClient.baseUrlForSharedClient == nil {
            APIClient.baseUrlForSharedClient = baseURL
        }
        else {
            throw APIClientError("\(type(of: APIClient.self)) singleton was already initialized!")
        }
    }
    
    private static var baseUrlForSharedClient: URL!
    public private(set) var baseURL: URL
    
    /// Usually UIAppDelegate is set as delegate.
    public weak var delegate: APIClientDelegate?
    
    private let sessionManager: Session
    private let reachability = try! Reachability()
    
    /// Client code can use preconfigured version of APIClient via `shared` property.
    public required init(baseURL: URL, manager: Session) {
        self.baseURL = baseURL
        self.sessionManager = manager
    }
    
    /// Sends request to server
    /// 
    /// See comment to `typedResponse<T: Decodable>(_:, completionHandler:)` for details how to get response of the
    /// specified type.
    ///
    /// `Content-Type` header is set automatically to `application/json` or to
    /// `application/x-www-form-urlencoded; charset=utf-8` according to the value in the `request.encoder`.
    /// Result is returned on main thread.
    @discardableResult public func sendRequest(request: RestAPIRequest) -> DataRequest {
        var url: URL! = request.absoluteURL
        if url == nil {
            url = baseURL.appendingPathComponent(request.relativeURL)
        }
        let dataRequest = sessionManager.request(url,
                                                 method: request.httpMethod,
                                                 parameters: AnyEncodable(request.parameters),
                                                 encoder: request.encoder,
                                                 headers: HTTPHeaders(request.httpHeaders),
                                                 interceptor: nil)
        return dataRequest.validateForErrors(apiClient: self)
    }
}

private extension DataRequest {
    
    func validateForErrors(apiClient: APIClient) -> Self {
        let dataRequest = validate { (urlRequest, urlResponse, data) -> Request.ValidationResult in
            
            if let error = apiClient.delegate?.apiClient(apiClient, urlResponse: urlResponse, data: data) {
                return Request.ValidationResult.failure(error)
            }
            else {
                return Request.ValidationResult.success(Void())
            }
        }
        return dataRequest
    }
    
}

/// Idea was taken from https://medium.com/@sergey.gavrilyuk/dynamic-encodable-with-type-erasure-1875722b3171
/// This struct allows to  have `APIRequest.parameters` property as having `Encodable` type rather then use some generic type constrained
/// to `Encodable`. In latter case `APIRequest` imposes additional requirements to its clients. For example client cannot have heterogenious
/// array of requests, or use `APIRequest` as a type, which won't allow to use fabric method patter for overriding type of  request in subclass.
private struct AnyEncodable: Encodable {
  var _encodeFunc: (Encoder) throws -> Void
  
  init(_ encodable: Encodable) {
    func _encode(to encoder: Encoder) throws {
      try encodable.encode(to: encoder)
    }
    self._encodeFunc = _encode
  }
  func encode(to encoder: Encoder) throws {
    try _encodeFunc(encoder)
  }
}
