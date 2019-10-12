import Alamofire


/**
 Encodable so that to have pissibility to save into persistent storage as property list.
 Also comparing of two objects is based on comparing of their serialized versions.
 */
protocol APIRequest {
    
    /// Endpoint URL.
    /// Allows to change URL for the given request.
    /// If `nil` then APIClient uses some default value.
    /// For REST requests is used as base URL, for requests with fixed endpoint is used as absolute URL.
    /// - note: Can be useful to provide stub for the response to the given request. Just provide file with needed content
    /// of response and set this property to appropriate file URL.
    var URL: String? { get }
    
    var httpMethod: HTTPMethod { get }
    
    var parameters: [String : Any]? {get}
    
    var httpHeaders: [String : String]? { get }
}


extension APIRequest {
    
    // Default implementation for `URL` property.
    // Adding this property to some base class is bad idea because base class will have to provide default implementation 
    // for methods of all protocols that it conforms to, and thus will non allow compile-time checking whether all needed
    // methods are implemented when creating new subclass for some request.
    var URL: String? {
        get {
            return nil
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var httpHeaders: [String : String]? {
        return nil
    }
}

