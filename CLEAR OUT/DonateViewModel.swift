//
//  DonateViewModel.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import CoreLocation
import MapKit
import Combine


class DonateViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private let locationUpdateThreshold: Double = 500 // meters
    @Published var donationCenters: [DonationCenter] = []
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        if let lastLocation = self.lastLocation, currentLocation.distance(from: lastLocation) < locationUpdateThreshold { return }
        
        self.lastLocation = currentLocation
        fetchDonationCenters(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
    }
    
    func fetchDonationCenters(latitude: Double, longitude: Double) {
        let apiKey = APIKeys.googlePlaces
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=5000&keyword=donation+center&key=\(apiKey)"
        
        guard let url = URL(string: urlString), let userLocation = lastLocation else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data {
                do {
                    let placesResponse = try JSONDecoder().decode(PlacesResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.donationCenters = placesResponse.results.compactMap { place -> DonationCenter? in
                            let centerLocation = CLLocation(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
                            let distance = userLocation.distance(from: centerLocation)
                            return DonationCenter(
                                name: place.name,
                                address: place.vicinity,
                                operationalHours: "Hours not available",
                                acceptedDonationTypes: "Various",
                                coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng),
                                distance: distance
                            )
                        }
                        self?.updateDistancesForDonationCenters(userLocation: userLocation)
                    }
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
        }.resume()
    }

    func updateDistancesForDonationCenters(userLocation: CLLocation) {
        donationCenters.forEach { center in
            let centerLocation = CLLocation(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
            center.distance = userLocation.distance(from: centerLocation)
        }
        donationCenters.sort()
    }


    
    // Remember to handle authorization changes if needed
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location authorization granted.")
            manager.startUpdatingLocation()
        case .denied:
            print("Location authorization denied. Please enable access in settings.")
        case .notDetermined:
            print("Location authorization not determined. Requesting authorization...")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location access restricted.")
        @unknown default:
            print("Unknown location authorization status.")
        }
    }

}
