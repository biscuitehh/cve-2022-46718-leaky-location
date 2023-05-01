//
//  RootView.swift
//  CoreParsecLocation
//
//  Created by Michael Thomas on 9/20/22.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var locationManager: SeemsLegitLocationManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text(locationManager.currentLocation)
            }
            Divider()
            HStack {
                Image(systemName: "person.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text(locationManager.currentUserID)
            }
        }
        .padding()
        .onAppear {
            locationManager.startUpdatingLocation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(locationManager: SeemsLegitLocationManager())
    }
}
