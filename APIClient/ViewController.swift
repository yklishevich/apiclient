//
//  ViewController.swift
//  Networking
//
//  Created by Yauheni Klishevich on 15/09/2019.
//  Copyright © 2019 YKL. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let _ = self.downloadOrUpdateUser { (error) in
            if error != nil {
                // error must have already been printed
            }
        }
    }
    
    /**
     Returned `DataRequest` allows to cancel task.
     */
    private func downloadOrUpdateUser(completion: ((Error?) -> Void)?) -> DataRequest {
        let userRequest = UserRequest()
        let dataRequest = APIClient.shared.sendRequest(request: userRequest).typedResponse(User.self) {
            (response) in
            
            switch response.result {
            case .success(let user):
                DispatchQueue.global(qos: .userInitiated).async {

                    print("User: \(user)")
                    
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                }
                
            case .failure(let error):
                print("Error: \(String(describing: error))")
                completion?(error)
            }
        }
        return dataRequest
    }
    
    
}

