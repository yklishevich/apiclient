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
        precondition(APIClient.baseUrlForSharedClient != nil, "Singleton must be initialize using `initShared(baseURL:)`")
        
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
    
    /// Client code can create use preconfigured version of APIClient via `shared` property.
    public required init(baseURL: URL, manager: Session) {
        self.baseURL = baseURL
        self.sessionManager = manager
    }
    
    /// Sends request to server
    /// See comment to `typedResponse<T: Decodable>(_:, completionHandler:)` for details how to get response of the
    /// specified type.
    /// Result is returned on main thread.
    @discardableResult public func sendRequest<T: RestAPIRequest>(request: T) -> DataRequest {
        //        let urlString = restApiRequest.URL ?? (baseURL + restApiRequest.relativeURL)
        //
        //        let dataRequest = sessionManager.request(urlString,
        //                                                 method: restApiRequest.httpMethod,
        //                                                 parameters: restApiRequest.parameters,
        //                                                 encoding: restApiRequest.encoder,
        //                                                 headers: HTTPHeaders(restApiRequest.httpHeaders))
        
        let urlRequestConvertible = APIClientURLRequestConvertible(restApiRequest: request,
                                                                   baseURL: self.baseURL)
        let dataRequest = sessionManager.request(urlRequestConvertible)
        
        return dataRequest.validateForErrors(apiClient: self)
    }
}

private struct APIClientURLRequestConvertible<T: RestAPIRequest> : URLRequestConvertible {
    let restApiRequest: T
    let baseURL: URL
    
    func asURLRequest() throws -> URLRequest {
        var url: URL? = restApiRequest.URL
        if url == nil {
            url = baseURL.appendingPathComponent(restApiRequest.relativeURL)
        }
        
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = restApiRequest.httpMethod.rawValue
        urlRequest = try restApiRequest.encoder.encode(restApiRequest.parameters, into: urlRequest)
        
        return urlRequest
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
