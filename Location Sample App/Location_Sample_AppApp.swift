//
//  Location_Sample_AppApp.swift
//  Location Sample App
//
//  Created by Rashard Longino Sr. on 5/19/21.
//

import SwiftUI

@main
struct Location_Sample_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
