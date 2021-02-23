//
//  APICaller.swift
//  groov
//
//  Created by Alice Wu on 2/22/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedtoGetData
    }
    
    public func getCurrentTrack(completion: @escaping (Result<CurrentTrack, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/player/currently-playing"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedtoGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(CurrentTrack.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                    print("User is not listening to any tracks right now :(")
                }
            }
            task.resume()
        }
    }
    
    public func getTopTracks(completion: @escaping (Result<RankedTrack, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/tracks?limit=5"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedtoGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RankedTrack.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
