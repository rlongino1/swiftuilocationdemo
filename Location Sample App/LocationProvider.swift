//
//  LocationProvider.swift
//  Location Sample App
//
//  Created by Rashard Longino Sr. on 5/20/21.
//

import Foundation
import CoreLocation
import CoreData

class LocationProvider: NSObject {
    
    private let locationManager = CLLocationManager()
    var delegate: LocationProviderDelegate?
    // @Environment(\.managedObjectContext) private var viewContext
    
    public var currentLocation: CLLocation? {
        return self.locationManager.location
    }
    private var mostRecentLocation: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func acquireCurrentLocation() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationProvider: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .notDetermined:
            // Do Nothing
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
        self.mostRecentLocation = location
        self.locationManager.stopUpdatingLocation()
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

extension LocationProvider {
    
    func saveLocation() {
        
        if let _mostRecentLocation = mostRecentLocation {
            let viewContext = PersistenceController.shared.container.viewContext
            
            let savedLocation = Item(context: viewContext)
            savedLocation.latitude = _mostRecentLocation.latitude
            savedLocation.longitude = _mostRecentLocation.longitude
            savedLocation.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
    }
}
