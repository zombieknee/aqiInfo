//
//  AQI.swift
//  AirQualityInfo
//
//  Created by Clinton Sexton on 4/21/24.
//

import UIKit
import CoreLocation


class AQI: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sationIDLabel: UILabel!
    @IBOutlet weak var yesterdayView: UIView!
    @IBOutlet weak var todayView: UIView!
    @IBOutlet weak var tomorrowView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var gpsButton: UIButton!
    
    let locationManager = CLLocationManager()
    var currentLocValue = CLLocationCoordinate2D()
    let restReq = RestController()
    
    @IBAction func testAPI(_ sender: Any) {
        print("Button Press")
        Task { @MainActor in
            guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
            try await restReq.getLatestMeasurementByCoord(withCoord: "\(locValue.latitude),\(locValue.longitude)")
        }
    }
    
    @IBAction func getCurrentLocationButtonPressed() {
       getLocation()
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.requestWhenInUseAuthorization()
        guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        Task {
            try await restReq.getLatestMeasurementByCoord(withCoord: "\(locValue.latitude),\(locValue.longitude)")
        }
        
        
        currentLocValue = locValue
        // Do any additional setup after loading the view.
        latitude.text = String(format: "%.3f", currentLocValue.latitude)
        longitude.text = String(format: "%.3f", currentLocValue.longitude)
        
//        cityLabel =
    }
    
     func getLocation() {
         guard CLLocationManager.locationServicesEnabled() else {
             print("Location services are disabled on your device. In order to use this app, go to " +
                   "Settings → Privacy → Location Services and turn location services on.")
             return
         }
         
         guard let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
         print("locations = \(locValue.latitude) \(locValue.longitude)")
         let authStatus = locationManager.authorizationStatus
         guard authStatus == .authorizedWhenInUse else {
               switch authStatus {
               case .denied, .restricted:
                   print("This app is not authorized to use your location. In order to use this app, " +
                     "go to Settings → AirQualityInfo → Location and select the \"While Using " +
                     "the App\" setting.")
                   
                 case .notDetermined:
                   locationManager.requestWhenInUseAuthorization()
                   
                 default:
                   print("Oops! Shouldn't have come this far.")
               }
               
               return
             }
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.startUpdatingLocation()
       }
       
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    // This is called if:
    // - the location manager is updating, and
    // - it was able to get the user's location.\

   
}

