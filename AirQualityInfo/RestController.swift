//
//  RestController.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/22/24.
//

import Foundation
import UIKit


// MARK: - Weather.gov Api handling
struct  WeatherGovJSON: Codable {
    let properties: StationLocation
}

struct StationLocation: Codable {
    let gridId: String
    let gridX: Int
    let gridY: Int
}

struct WeatherGovStationJSON: Codable {
    let features: [StationInfo]
}

struct StationInfo: Codable {
    let properties: StationProperties
}

struct StationProperties: Codable {
    let stationIdentifier: String
}

// MARK: - AirNow Api Handling
struct AirNowForecastResult: Codable {
    let DateForecast: String
    let ParameterName: String
    let AQI: Int
    let Category: Category
}

struct AirNowResult: Codable {
    let DateObserved: String
    let ReportingArea: String
    let Latitude: Double
    let Longitude: Double
    let ParameterName: String
    let AQI: Int
    let Category: Category
}
struct Category: Codable {
    let Name: String
}

enum GenericError: Error {
        case unknown
}
class RestController{
    
    func airNowAPIForcast(withLat lat: String, andLong long: String, forDay day: Date) async throws -> [AirNowForecastResult] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDay = formatter.string(from: day)
        guard let url = URL(string: "https://www.airnowapi.org/aq/forecast/latLong/") else { throw URLError(.unsupportedURL) }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "format", value: "application/json"),
            URLQueryItem(name: "latitude", value: lat),
            URLQueryItem(name: "longitude", value: long),
            URLQueryItem(name: "date", value: strDay),
            URLQueryItem(name: "api_key", value: "4407AAEE-4201-4F2F-B7EE-953C0776B812")
        ]
        
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GenericError.unknown
        }
        
        return try JSONDecoder().decode([AirNowForecastResult].self, from: data)
    }
    func airNowAPIToday(withLat lat: String, andLong long: String) async throws -> [AirNowResult]{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDay = formatter.string(from: Date())
        guard let url = URL(string: "https://www.airnowapi.org/aq/observation/latLong/current") else { throw URLError(.unsupportedURL)}
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "format", value: "application/json"),
            URLQueryItem(name: "latitude", value: lat),
            URLQueryItem(name: "longitude", value: long),
            URLQueryItem(name: "date", value: strDay),
            URLQueryItem(name: "api_key", value: "4407AAEE-4201-4F2F-B7EE-953C0776B812")
        ]
        
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GenericError.unknown
        }
        
        return try JSONDecoder().decode([AirNowResult].self, from: data)
        
    }
    func getWeatherStationLoc(forLat lat: String, andLong long: String) async throws -> WeatherGovJSON {
        guard let url = URL(string: "https://api.weather.gov/points/\(lat),\(long)") else {  throw URLError(.unsupportedURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GenericError.unknown
        }
        
        return try JSONDecoder().decode(WeatherGovJSON.self, from: data)
    }
    
    func getWeatherStationCode(forGrid grid: String, xPos gridX: String, yPos gridY: String) async throws -> WeatherGovStationJSON {
        guard let url = URL(string: "https://api.weather.gov/gridpoints/\(grid)/\(gridX),\(gridY)/stations") else { throw URLError(.unsupportedURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GenericError.unknown
        }
        
        return try JSONDecoder().decode(WeatherGovStationJSON.self, from: data)
    }

}

