//
//  RestController.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/22/24.
//

import Foundation
import UIKit

typealias RequestHandler = (Result<Dictionary<String,Any>, Error>) -> Void

class RestController{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func getCitties(completion:@escaping RequestHandler) {
        let url = URL(string: "https://api.openaq.org/v2/cities")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "sort", value: "asc"),
            URLQueryItem(name: "order_by", value: "city"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
            
        sendRequest(withRequest: request, withQureyItems: queryItems) { result in
            switch result {
            case .success(let json):
                print("JSON: \(json)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func getLatestMeasuermentByID(completion:@escaping RequestHandler) {
//TODO:        need to pass in location ID based on GPS coords
        let url = URL(string: "https://api.openaq.org/v2/latest/location_id")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        sendRequest(withRequest: request, withQureyItems: nil) { result in
            switch result {
            case .success(let json):
                print("JSON: \(json)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendRequest(withRequest req: URLRequest, withQureyItems querty: [URLQueryItem]?, completion:@escaping RequestHandler) {
        var req = req
        
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: req) { (data, jsonResponse, error) in
            if let error : Error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(.success(jsonResponse!))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}


