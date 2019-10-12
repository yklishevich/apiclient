/**
 Used for networking in projects with fixed endpoint, that is for projects not using REST.
 */
protocol FixedEndpointApiRequest: APIRequest {
    
    /// Request name.
    /// Request name is specific for networking with fixed endpoint and is used to identify the request to the server.
    /// For example in request "http://admin.i-event.org:8080/ApiHandlers/Mobile.ashx?action=load-sprav" this name is
    /// passed as action parameter.
    /// Conforming type can return `nil` to indicate that name is not used, which is the case for example in case of REST
    /// service.
    static var RequestName: String {get}
}
