//
//  SoundCloudNetworking.swift
//  soundcloudApp
//
//  Created by pioner on 24.09.2021.
//

import Foundation
import AVKit

class SoundCloudNetworking {
    
    static let shared = SoundCloudNetworking()
    
    private let clientID = "08cb4bc9efc7ebeb5945abe37ae11b39"
    private let clientSecret = "43d7b47398b1e57bf05a6f8ce0cc8a49"
    
    private var attemptGetTraks = 0
    
    private init(){}
    
    func getToken(comletionHandler: @escaping ()->Void ){
        let url = URL(string: "https://api.soundcloud.com/oauth2/token")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "client_credentials"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret)
        ]

        let query = components.url!.query
        
        request.httpBody = Data(query!.utf8)
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("is not data")
                return
            }
            
            if let httpUrlResponse = response as? HTTPURLResponse {
                if httpUrlResponse.statusCode != 200 {
                    print("response status code is not 200")
                    return
                }
            }
            
            do {
                guard let dataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return}
                
                guard let accessToken = dataDict["access_token"] as? String else {return}
                
                self.saveToken(token: accessToken)
                comletionHandler()
                
            } catch {
                print(error.localizedDescription)
                return
            }
        }.resume()
    }
    
    func getTokenUserPass(userName: String, password: String, comletionHandler: @escaping ()->Void ){
        let url = URL(string: "https://api.soundcloud.com/oauth2/token")
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "password"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "username", value: userName),
            URLQueryItem(name: "password", value: password)
        ]

        let query = components.url!.query
        
        request.httpBody = Data(query!.utf8)
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("is not data")
                return
            }
            
            if let httpUrlResponse = response as? HTTPURLResponse {
                if httpUrlResponse.statusCode != 200 {
                    print("response status code is not 200")
                    return
                }
            }
            
            do {
                guard let dataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {return}
                
                guard let accessToken = dataDict["access_token"] as? String else {return}
                
                self.saveToken(token: accessToken)
                print(accessToken)
                comletionHandler()
                
            } catch {
                print(error.localizedDescription)
                return
            }
        }.resume()
    }
    
    func getTracks(search: String,limit: Int, completionHandler: @escaping (_ responseTracks: ResponseTracks)->Void) {
        
        guard let search = search.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return}
        
        let strngUrl = "https://api.soundcloud.com/tracks?q=\(search)&access=&limit=\(limit)&linked_partitioning=true"
        
        guard let url = URL(string: strngUrl) else {return}
        
        guard let token = getSavedToken() else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "accept")
        request.addValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { [self] (data, response, error) in
            
            if let err = error {
                print(err.localizedDescription)
                return
            }
            
            guard let data = data, let response = response else {
                print("not data")
                return
            }
            
            if let httpUrlResponse = response as? HTTPURLResponse {
                
                if httpUrlResponse.statusCode != 200 {
                    if self.attemptGetTraks <= 3 {
                        self.attemptGetTraks += 1
                        getToken {
                            getTracks(search: search, limit: limit) { (responseTracks) in
                                completionHandler(responseTracks)
                            }
                        }
                    }
                    
                    self.attemptGetTraks = 0
                    print("Response Status code \(httpUrlResponse.statusCode)")
                    return
                }
            }
            
            do {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let response = try decoder.decode(ResponseTracks.self, from: data)
                
                self.attemptGetTraks = 0
                
                DispatchQueue.main.async {
                    completionHandler(response)
                }
                
            } catch {
                print(error.localizedDescription)
                return
            }
            
        }.resume()
        
    }
    
    private func saveToken(token: String) {
        KeyChain.shared["token"] = token
    }
    
    func getSavedToken() -> String? {
        return KeyChain.shared["token"]
    }
    
    func removeSevedToken() {
        KeyChain.shared["token"] = nil
    }
    
    func getImage(urlString: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if error != nil {return}
            
            guard let data = data else {return}
            
            guard let image = UIImage(data: data) else {return}
            
            DispatchQueue.main.async {
                completionHandler(image)
            }
            
        }).resume()
        
    }
    
    
    
}
