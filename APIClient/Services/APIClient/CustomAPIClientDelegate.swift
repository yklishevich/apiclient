//
//  Created by Yauheni Klishevich on 12/10/2019.
//  Copyright © 2019 WPA. All rights reserved.
//

import Foundation

class CustomAPIClientDelegate: APIClientDelegate {
    
     func apiClient(_ apiClient: APIClient,
                    urlResponse: HTTPURLResponse,
                    data: Data?) -> APIClientError? {
        
        if let error = self.checkAppVersion(urlResponse) {
            return error
        }
        else if let error = self.checkWhetherServerIsOnMaintenance(urlResponse) {
            return error
        }
            
        else if (200 ... 299).contains(urlResponse.statusCode) == false {
            return self.errorResponseToAPIClientError(data: data)
        }
        else {
            return nil
        }
    }
    
    private func errorResponseToAPIClientError(data: Data?) -> APIClientError? {
        if let theData = data {
            do {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: theData)
                
                if errorResponse.code == HTTPURLResponse.StatusCode.Http401_Unauthorized.rawValue {
                    return APIUnauthorizedError(status: errorResponse.code, message: errorResponse.message)
                }
                else {
                    return APIRemoteError(status: errorResponse.code, message: errorResponse.message)
                }
            }
            catch let desirializationError {
                return APIRuntimeError(underlyingError: desirializationError)
            }
        }
        else {
            return APIRuntimeError("Body of response is empty!")
        }
    }
    
    private class ErrorResponse: Decodable {
        let code: Int
        let message: String?
    }
    
    private func checkAppVersion(_ urlResponse: HTTPURLResponse) -> APIIncompatibleAppVersionError? {
        if let minRequiredAppVersion = getMinRequiredAppVersionFrom(urlResponse) {
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            
            if appVersion.compare(minRequiredAppVersion, options: .numeric) == .orderedAscending {
                return APIIncompatibleAppVersionError(appVersion: appVersion, minRequiredVersion: minRequiredAppVersion)
            }
        }
        
        return nil
    }
    
    private func checkWhetherServerIsOnMaintenance(_ urlResponse: HTTPURLResponse) -> APIServerOnMaintenanceError? {
        // example: "api: 1.0.0, android: 1.2.7, ios: 1.0.1, block: -" or "block: {Some message to display to user}"
        if let headerWithMaintenanceMessage = urlResponse.allHeaderFields["X-App-Version"] as? String,
            let blockRelatedRange = headerWithMaintenanceMessage.range(of: #"(?<=block: )[^,]*"#,
                                                                       options: .regularExpression) {
            let message = String(headerWithMaintenanceMessage[blockRelatedRange])
            if message != "-" {
                return APIServerOnMaintenanceError(message)
            }
        }
        
        return nil
    }
    
    private func getMinRequiredAppVersionFrom(_ urlResponse: HTTPURLResponse) -> String? {
        // example: "api: 1.0.0, android: 1.2.7, ios: 1.0.1"
        if let headerWithMinRequiredAppVersion = urlResponse.allHeaderFields["X-App-Version"] as? String,
            let iosRelatedRange = headerWithMinRequiredAppVersion.range(of: #"(?<=ios: )[\d.]*"#,
                                                                        options: .regularExpression) {
            return String(headerWithMinRequiredAppVersion[iosRelatedRange])
        }
        else {
            return nil
        }
    }
    
}

extension HTTPURLResponse {
    public enum StatusCode: Int {
        case Http401_Unauthorized = 401
    }
}
