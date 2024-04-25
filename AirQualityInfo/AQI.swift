//
//  AQI.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/21/24.
//

import UIKit
import CoreLocation


class AQI: UIViewController, CLLocationManagerDelegate {
    
    enum LoadError: Error {
        case fetchFailed, decodeFailed
    }
    
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var todayView: UITextView!
    @IBOutlet weak var tomorrowView: UITextView!
    @IBOutlet weak var yesterdayView: UITextView!
    @IBOutlet weak var sationIDLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
    let restReq = RestController()
    
    var todayInfo = String()
    var tomorrowInfo = String()
    var yesterdayInfo = String()
    
    var today = Date()
    var tomorrow = String()
    var yesterday = String()
    
    func setupTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let tmp = Calendar.current.date(byAdding: .day, value: 1, to: today) {
            tomorrow = formatter.string(from:tmp)
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "Time has broken", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if let tmp = Calendar.current.date(byAdding: .day, value: -1, to: today) {
            yesterday = formatter.string(from:tmp)
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "Time has broken", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestWhenInUseAuthorization()
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        setupTime()
        
        Task {
            
            let aqiToday = try await restReq.airNowAPIToday(withLat: "\(locValue.latitude)", andLong: "\(locValue.longitude)")
            let aqiForcast = try await restReq.airNowAPIForcast(withLat: "\(locValue.latitude)",
                                                                andLong: "\(locValue.longitude)",
                                                                forDay: formatter.date(from: tomorrow) ?? today)
            let aqiYesterday  = try await restReq.airNowAPIForcast(withLat: "\(locValue.latitude)",
                                                                   andLong: "\(locValue.longitude)",
                                                                   forDay: formatter.date(from: yesterday) ?? today)
            
            let station = try await restReq.getWeatherStationLoc(forLat: "\(locValue.latitude)", andLong: "\(locValue.longitude)")
            
            let stationCodes = try await restReq.getWeatherStationCode(forGrid: station.properties.gridId,
                                                                       xPos: "\(station.properties.gridX)",
                                                                       yPos: "\(station.properties.gridY)")
            
            
            
            self.todayInfo = "The AQI is \(aqiToday[0].AQI) for \(aqiToday[0].ParameterName) which is \(aqiToday[0].Category.Name) for Today"
            self.yesterdayInfo = "The AQI was \(aqiYesterday[0].AQI) for \(aqiYesterday[0].ParameterName) which was \(aqiYesterday[0].Category.Name) for Yesterday"
            self.tomorrowInfo = "The AQI is \(aqiForcast[0].AQI) for \(aqiForcast[0].ParameterName) which is \(aqiForcast[0].Category.Name) for Tomorrow"
            
            todayView.text = todayInfo
            tomorrowView.text = tomorrowInfo
            yesterdayView.text = yesterdayInfo
            
            cityLabel.text = aqiToday[0].ReportingArea
            let stationCode = stationCodes.features
            
            sationIDLabel.text = stationCode[0].properties.stationIdentifier 
        }
        
        // Do any additional setup after loading the view.
        latitude.text = String(format: "%.3f", locValue.latitude)
        longitude.text = String(format: "%.3f", locValue.longitude)
    }
 
}

