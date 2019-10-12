
import Foundation

public protocol RestAPIRequest: APIRequest {
    
    /**
     If `URL` property is not set then absolute URL is made up from base URL in APIClient and this value.
     */
    var relativeURL: String { get }
}
