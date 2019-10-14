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
        precondition(APIClient.sBaseURL != nil, "Singleton must be initialize using `initShared(baseURL:)`")
        
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
                return APIClient(baseURL: APIClient.sBaseURL, manager: sessionManager)
        }
        
        return apiClientClass.init(baseURL: APIClient.sBaseURL, manager: sessionManager)
    }()
    
    public static func initShared(baseURL: URL) throws {
        if APIClient.sBaseURL == nil {
            APIClient.sBaseURL = baseURL.absoluteString
        }
        else {
            throw APIClientError("\(type(of: APIClient.self)) singleton was already initialized!")
        }
    }
    
    private static var sBaseURL: String!
    public private(set) var baseURL: String
    
    /// Usually UIAppDelegate is set as delegate.
    public weak var delegate: APIClientDelegate?
    
    private let sessionManager: Session
    private let noNetworkSessionManager: Session
    private let reachability = try! Reachability()
    
    /// Client code can create use preconfigured version of APIClient via `shared` property.
    public required init(baseURL: String, manager: Session) {
        self.baseURL = baseURL
        self.sessionManager = manager
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 0.0001 // 0 value leads to default 60 value.
        self.noNetworkSessionManager = Session(configuration: configuration)
    }
    
    @discardableResult public func sendRequest(apiRequest: APIRequest) -> DataRequest {
        let theSessionManager = reachability.connection != .unavailable ? sessionManager : noNetworkSessionManager
        
        switch apiRequest {
            
        case let fixedEndpointApiRequest as FixedEndpointApiRequest:
            let url = apiRequest.URL ?? baseURL
            return theSessionManager.request(url,
                                             method: .get,
                                             parameters: fixedEndpointApiRequest.parameters,
                                             encoding: URLEncoding.default)
            
        case let restApiRequest as RestAPIRequest:
            let urlString = restApiRequest.URL ?? (baseURL + restApiRequest.relativeURL)
            
            let encoding: ParameterEncoding =
                (restApiRequest.httpMethod == .get) ? URLEncoding.default : JSONEncoding.default
            
            let dataRequest = theSessionManager.request(urlString,
                                                        method: restApiRequest.httpMethod,
                                                        parameters: restApiRequest.parameters,
                                                        encoding: encoding,
                                                        headers: HTTPHeaders(restApiRequest.httpHeaders ?? [:]))
            
            return dataRequest.validateForErrors(apiClient: self)
            
        default:
            fatalError("Unknown type of request: \(apiRequest)!")
        }
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
