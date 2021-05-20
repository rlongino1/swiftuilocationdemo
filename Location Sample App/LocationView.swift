//
//  LocationView.swift
//  Location Sample App
//
//  Created by Rashard Longino Sr. on 5/20/21.
//

import SwiftUI

struct LocationView: View {
    @EnvironmentObject var locationModel: LocationObservable
    
    var body: some View {
        VStack {
            Button(action: {
                locationModel.locationManager.acquireCurrentLocation()
            }) {
                Text("Get location")
            }
            Button(action: {
                locationModel.locationManager.saveLocation()
            }) {
                Text("Save location")
            }
            Text("Latitude: \(locationModel.currentLatitude)")
            Text("Longitude: \(locationModel.currentLongitude)")
        }
        .alert(isPresented: $locationModel.alertToShow, content: {
            Alert(title: Text("Notification"), message: Text(locationModel.errorMessage ?? "No message available"), dismissButton: .default(Text("OK")))
        })
        
        
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
    }
}
