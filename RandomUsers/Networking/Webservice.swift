//
//  Webservice.swift
//  RandomUsers
//
//  Created by Magdalena Szlagor on 18/03/2018.
//  Copyright © 2018 Magdalena Szlagor. All rights reserved.
//

import Foundation

final class WebService {
    func load<A>(resource: Resource<A>, completion: @escaping (Result<A>) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, response, error in
            // Check for errors in responses.
            let result = self.checkForNetworkErrors(data, response, error)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    completion(resource.parse(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            }.resume()
    }
}

extension WebService {
    
    fileprivate func checkForNetworkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data> {
        
        if let error = error {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && (nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut) {
                return .failure(.noInternetConnection)
            } else {
                return .failure(.returnedError(error))
            }
        }
        
        if let response = response as? HTTPURLResponse, response.statusCode <= 200 && response.statusCode >= 299 {
            return .failure((.invalidStatusCode("Request returned status code other than 2xx \(response)")))
        }
        
        guard let data = data else { return .failure(.dataReturnedNil) }
        
        return .success(data)
    }
    
    public static func parseUserFeedResponse(withURL: URL) -> Resource<UsersPageModel> {
        
        let parse = Resource<UsersPageModel>(url: withURL, parseJSON: { jsonData in
            
            guard let json = jsonData as? JSONDictionary, let users = json["results"] as? [JSONDictionary] else { return .failure(.errorParsingJSON)  }
            
            guard let model = UsersPageModel(dictionary: json, usersArray: users.flatMap(UserModel.init)) else { return .failure(.errorParsingJSON) }
            
            return .success(model)
        })
        
        return parse
    }
}

struct Resource<A> {
    let url: URL
    let parse: (Data) -> Result<A>
}

extension Resource {
    
    init(url: URL, parseJSON: @escaping (Any) -> Result<A>) {
        self.url = url
        self.parse = { data    in
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
                return parseJSON(jsonData)
            } catch {
                fatalError("Error parsing data")
            }
        }
    }
}

enum Result<T> {
    case success(T)
    case failure(NetworkingErrors)
}

enum NetworkingErrors: Error {
    case errorParsingJSON
    case noInternetConnection
    case dataReturnedNil
    case returnedError(Error)
    case invalidStatusCode(String)
    case customError(String)
}
