import Alamofire


// MARK: – Alamofire.DataRequest

public extension DataRequest {
    
    /// Allows to get response from server in deserialized form, using provided type as type of being returned object.
    /// For empty response use "EmptyModel" type as value of generic parameter T.
    /// If response is represented by array then pass `[SomeType].type` as an argument.
    /// Example:
    ///     apiClient.sendRequest(apiRequest: deliveryMomentsRequest).typedResponse([DeliveryMoment].self) {
    ///         (response) in
    ///         ...
    ///     }
    ///
    /// Errors being returned in `DataResponse.result.failure` are of type `APIError`.
    @discardableResult
    func typedResponse<T: Decodable>(_ type: T.Type,
                                     completionHandler: @escaping (DataResponse<T, APIClientError>) -> Void) -> Self {
        
        return self.responseObject(T.self) { (response: AFDataResponse<T>) in
            switch response.result {
                
            case .success(let value):
                
                let translatedResult = Result<T, APIClientError>.success(value)
                let dataResponse: DataResponse<T, APIClientError> = DataResponse(request: response.request,
                                                                           response: response.response,
                                                                           data: response.data,
                                                                           metrics: self.metrics,
                                                                           serializationDuration: 0,
                                                                           result: translatedResult)
                completionHandler(dataResponse)
                
            case .failure(let error):
                let apiError = APIClientError.apiErrorFrom(error)
                
                let translatedResult: Result<T, APIClientError>? = .failure(apiError)
                
                let dataResponse: DataResponse<T, APIClientError> = DataResponse(request: response.request,
                                                                           response: response.response,
                                                                           data: response.data,
                                                                           metrics: self.metrics,
                                                                           serializationDuration: 0,
                                                                           result: translatedResult!)
                
                // log.debug(String(data: response.data!, encoding: String.Encoding.utf8) ?? "Data could not be printed")
                
                completionHandler(dataResponse)
            }
        }
    }
    
}
