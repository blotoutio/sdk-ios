//
//  BOAServiceLayer.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 04/05/22.
//

import Foundation

class ServiceLayer {
    
    class func requestToGetModel<T: Codable>(router: BOARouter,body:Data?, completion: @escaping (Result<T, Error>) -> ()) {
        
        let apiEndPoint = router.resolveAPIEndPoint(BOUrlEndPoint.manifestPull)
        var urlRequest: URLRequest? = nil
        if let url = URL(string: apiEndPoint) {
            urlRequest = URLRequest(url: url)
        }
        else
        {
            return
        }
        
        if BOAReachability.sharedInstance.isConnected == false{
            print("NOT Connected")
            let networkError = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorNoInternetConnection.rawValue, withMessage: "Network Not Reachable")
            completion(.failure(networkError!))
        }
        
        if body != nil
        {
            urlRequest?.httpBody = body
        }
        
        urlRequest!.httpMethod = router.method
        urlRequest!.allHTTPHeaderFields = router.headerFields
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest!) { data, response, error in
            
            if let err = error {
                completion(.failure(err))
                print(err.localizedDescription)
                return
            }
            guard response != nil, let data = data else {
                return
            }
            
            do{
                let responseObject = try JSONDecoder().decode(T.self, from: data)
                
                DispatchQueue.main.async {
                    
                    let cookieName = "sdk_trends_user_id"//Constants.tag_user_id
                    if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == cookieName }) {
                        
                        BOAUtilities.saveDeviceID(cookieStr: cookie.value)
                       // StorageHandler.shared.saveCookie(cookieStr: cookie.value)
                        //save this value to pass back in
                    }
                    
                    
                    completion(.success(responseObject))
                }
            }
            catch
            {
                print("error is \(error.localizedDescription)")
                completion(.failure(error))
            }
            
        }
        dataTask.resume()
    }
    
    
    class func request(router: BOARouter,body:Data?, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        let apiEndPoint = router.resolveAPIEndPoint(BOUrlEndPoint.manifestPull)
        var urlRequest: URLRequest? = nil
        if let url = URL(string: apiEndPoint) {
            urlRequest = URLRequest(url: url)
        }
        else
        {
            return
        }
        
        if BOAReachability.sharedInstance.isConnected == false{
            print("NOT Connected")
            let networkError = BOErrorAdditions.boError(forCode: BOErrorCodes.boErrorNoInternetConnection.rawValue, withMessage: "Network Not Reachable")
            completion(.failure(networkError!))
        }
        
        
        if body != nil
        {
            urlRequest?.httpBody = body
        }
        
        urlRequest!.httpMethod = router.method
        urlRequest!.allHTTPHeaderFields = router.headerFields
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest!) { data, response, error in
            
            if let err = error {
                completion(.failure(err))
                print(err.localizedDescription)
                return
            }
            guard response != nil, let data = data else {
                return
            }
                
                DispatchQueue.main.async {
                    
                    completion(.success(true))
                }
            
        }
        dataTask.resume()
    }
}
