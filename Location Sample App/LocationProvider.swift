//
//  LocationProvider.swift
//  Location Sample App
//
//  Created by Rashard Longino Sr. on 5/20/21.
//

import Foundation
import CoreLocation

class LocationProvider: NSObject {
    
    private let locationManager = CLLocationManager()
    var delegate: LocationProviderDelegate?
    
    public var currentLocation: CLLocation? {
        return self.locationManager.location
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
    }
    
    public func acquireCurrentLocation() {
        self.locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .notDetermined:
            // Do Nothing
            self.delegate?.errorMessageReceived("Location Authorization Not Determined.")
            break
        case .authorizedWhenInUse:
            // Get Location
            self.locationManager.startUpdatingLocation()
            print("Authorized When in Use!")
            break
        case .authorizedAlways:
            // Get Location
            self.locationManager.startUpdatingLocation()
            print("Authorized Always!")
            break
        case .restricted:
            // Error Message
            self.delegate?.errorMessageReceived("Location Authorization Restricted.")
            break
        case .denied:
            // Error Message
            self.delegate?.errorMessageReceived("Location Authorization Denied.")
            break
        default:
            // Do Nothing
        
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Location Updated!")
        self.delegate?.locationDidUpdate(location)
        // self.geocode()
    }
}

protocol LocationProviderDelegate {
    func locationDidUpdate(_ locationData: CLLocation?)
    func errorMessageReceived(_ errorMsg: String)
}

class LocationObservable : ObservableObject, LocationProviderDelegate {
    
    func errorMessageReceived(_ errorMsg: String) {
        self.alertToShow = true
        self.errorMessage = errorMsg
    }
    
    func locationDidUpdate(_ locationData: CLLocation?) {
        self.observedLocation = locationData
        if let _observedLocation = self.observedLocation {
            currentLatitude = _observedLocation.latitude
            currentLongitude = _observedLocation.longitude
        }
    }
    
    @Published var observedLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var currentLatitude: Double = 0.0
    @Published var currentLongitude: Double = 0.0
    @Published var alertToShow = false
    var locationManager: LocationProvider = LocationProvider()
    
    init() {
        self.locationManager.delegate = self
    }
}

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
}
