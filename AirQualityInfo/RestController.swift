//
//  RestController.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/22/24.
//

import Foundation
import UIKit


struct JSONResult: Decodable {
//    var meta: Dictionary
    let results: [AQIResult]

}

struct AQIResult: Decodable {
    let location: String
    let city: String?
    let country: String
    let coordinates: Coords
    let measurements: [AQIMeasurement]
}
struct AQIMeasurement:Decodable {
    let parameter: String
    let value: Double
    let lastUpdated: String
    let unit: String
    let sourceName: String
}

struct Coords: Codable {
    let latitude: Double
    let longitude: Double
}



class RestController{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    func getCitties() async throws {
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
       
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(decoding: data, as: UTF8.self))

    }
    
    func getLocationByID () async throws{

        let url = URL(string: "https://api.openaq.org/v2/locations/2167")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "limit", value: "100"),
          URLQueryItem(name: "page", value: "1"),
          URLQueryItem(name: "offset", value: "0"),
          URLQueryItem(name: "sort", value: "asc"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(decoding: data, as: UTF8.self))
    }
    
    func getLatestMeasurementByCoord(withCoord coords: String) async throws {
        let url = URL(string: "https://api.openaq.org/v1/latest")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "sort", value: "desc"),
            URLQueryItem(name: "coordinates", value: "\(coords)"),
            URLQueryItem(name: "radius", value: "5000"),
            URLQueryItem(name: "order_by", value: "lastUpdated"),
            URLQueryItem(name: "dump_raw", value: "false"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "content-type": "application/json"
        ]

        let (data, response) = try await URLSession.shared.data(for: request)
        let jres: JSONResult = try! JSONDecoder().decode(JSONResult.self, from: data)
        
        print (jres)
    }
    
    func getLatestMeasuermentByID(withLocID locID: String) async throws {
        let url = URL(string: "https://api.openaq.org/v1/latest/\(locID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(decoding: data, as: UTF8.self))
    }
}


