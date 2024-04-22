//
//  AQI.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/21/24.
//

import UIKit
import CoreLocation

class AQI: UIViewController {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sationIDLabel: UILabel!
    @IBOutlet weak var yesterdayView: UIView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var tomorrowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //MARK: need this for location permission maybe
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            enableLocationFeatures()
            break
            
        case .restricted, .denied:  // Location services currently unavailable.
            disableLocationFeatures()
            break
            
        case .notDetermined:        // Authorization not determined yet.
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func enableLocationFeatures() {
        
    }
    
    func disableLocationFeatures() {
        
    }

}

