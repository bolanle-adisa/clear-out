//
//  DonationCenter.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//


import Foundation
import MapKit

class DonationCenter: NSObject, Identifiable, MKAnnotation {
    let id: UUID
    let name: String
    let address: String
    let operationalHours: String
    let acceptedDonationTypes: String
    var coordinate: CLLocationCoordinate2D

    init(id: UUID = UUID(), name: String, address: String, operationalHours: String, acceptedDonationTypes: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.address = address
        self.operationalHours = operationalHours
        self.acceptedDonationTypes = acceptedDonationTypes
        self.coordinate = coordinate
    }
}
