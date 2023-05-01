//
//  CoreParsecLocationApp.swift
//  CoreParsecLocation
//
//  Created by Michael Thomas on 9/20/22.
//

import SwiftUI

@main
struct CoreParsecLocationApp: App {
    @StateObject var sketchLocationManager = SeemsLegitLocationManager()

    var body: some Scene {
        WindowGroup {
            RootView(locationManager: sketchLocationManager)
        }
    }
}
