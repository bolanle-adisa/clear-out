//
//  DonateViewModel.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import CoreLocation
import MapKit

import CoreLocation
import Combine


class DonateViewModel: ObservableObject {
    @Published var donationCenters: [DonationCenter] = []

    func fetchDonationCenters() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(), let currentLocation = locationManager.location {
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            
            let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=5000&type=charity&key=AIzaSyAM58ClazlWyLomWPhqxaXaqx_oaWFC_pY"
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        // Assuming you have a struct to decode the response
                        let decodedResponse = try decoder.decode(PlacesResponse.self, from: data)
                        // Convert decoded response to [DonationCenter]
                        DispatchQueue.main.async {
                            self.donationCenters = decodedResponse.results.map { place -> DonationCenter in
                                // Map place to DonationCenter
                                return DonationCenter(
                                    name: place.name,
                                    address: place.vicinity,
                                    operationalHours: "Hours not available", // Google Places API might not provide this directly
                                    acceptedDonationTypes: "Various", // This info might not be available directly
                                    coordinate: CLLocationCoordinate2D(
                                        latitude: place.geometry.location.lat,
                                        longitude: place.geometry.location.lng
                                    )
                                )
                            }
                        }
                    } catch {
                        print("Error decoding response: \(error)")
                    }
                }
            }.resume()
        }
    }
}
