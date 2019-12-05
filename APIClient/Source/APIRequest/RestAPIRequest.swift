
import Foundation

public protocol RestAPIRequest: APIRequest {
    
    /**
     If `URL` property is not set then absolute URL is made up from base URL in APIClient and this value.
     Can eather start or do not start from leading slash '/'.
     For example:
        "/user/1"
        "user/1"
     */
    var relativeURL: String { get }
}
