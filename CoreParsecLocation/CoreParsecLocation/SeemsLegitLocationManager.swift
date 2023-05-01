//
//  SeemsLegitLocationManager.swift
//  CoreParsecLocation
//
//  Created by Michael Thomas on 9/20/22.
//

import Foundation
import Dynamic

@MainActor
class SeemsLegitLocationManager: ObservableObject {
    
    @Published var currentUserID: String = ""
    @Published var currentLocation: String = ""

    private var locationUpdateTimer: Timer?
    
    // How often should we ask `parsecd` for a new location
    private let kUpdateLocationInterval = 5.0
    
    // Other bits
    typealias ResponseBlock = @convention(block) (_ request: AnyObject, _ response: AnyObject?) -> Void
    typealias RecentResultsBlock = @convention(block) (_ results: AnyObject) -> Void
    
    init() {
        // First, we need to load our private frameworks
        let parsecTest = loadFramework(at: "/System/Library/PrivateFrameworks/CoreParsec.framework/CoreParsec")
        let spotlightTest = loadFramework(at: "/System/Library/PrivateFrameworks/Spotlight.framework/Spotlight")
        
        if parsecTest && spotlightTest {
            print("Requirements loaded.")
        } else {
            fatalError("An error occurred while loading a required framework!")
        }
    }
    
    func startUpdatingLocation() {
        updateLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: kUpdateLocationInterval,
                                                   target: self,
                                                   selector: #selector(updateLocation),
                                                   userInfo: nil,
                                                   repeats: true)
    }
    
    func stopUpdatingLocation() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    // MARK: Private Helpers
    
    private func loadFramework(at path: String) -> Bool {
        guard let _ = dlopen(path, RTLD_NOW) else {
            // TODO: Handle Error
            print("An error occurred while loading \(path)")
            return false
        }
        
        return true
    }
    
    @objc private func updateLocation() {
        // When we ask `parsecd` for "restaurants", it will ask for results from Apple Maps which
        // include a precise location. Other requests will include a "wifi" location which is based
        // on the user's IP address.
        
        // This is a shared object - there should only be one.
        let session = Dynamic.SPPARSession.spotlightPARSession()
        session.start()
        
        let request = Dynamic.PARRequest.lookupRequestWithString("restaurants", queryContext: nil, domain: nil, lookupSelectionType:1, appBundleId: "com.apple.spotLight", queryId: 0)
        
        let task = session.taskWithRequest(request, completion: { request, response in
            // Apologies for the parsing code, it's not stellar
            if response != nil {
                let newResponse = Dynamic(response)
                if let responseDict = newResponse.rawResponse.asArray?.firstObject as? Dictionary<String, AnyObject> {
                    self.handleResponse(response: responseDict)
                }
            }
        } as ResponseBlock)
        task.resume()
    }
    
    private func handleResponse(response: Dictionary<String, AnyObject>) {
        if let encodedQuery = response["fbq"] as? String,
           let data = Data(base64Encoded: encodedQuery),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, AnyObject> {
            
            if let userId = json["u"] as? String, let location = json["c"] as? String {
                DispatchQueue.main.async {
                    self.currentUserID = userId
                    self.currentLocation = location
                }
            }
        }
    }
}
