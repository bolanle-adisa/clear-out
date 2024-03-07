//
//  DonationCenter.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//


import Foundation
import MapKit

class DonationCenter: NSObject, Identifiable, MKAnnotation, Comparable {
    let id: UUID
    let name: String
    let address: String
    let operationalHours: String
    let acceptedDonationTypes: String
    var coordinate: CLLocationCoordinate2D
    var distance: CLLocationDistance?

    init(id: UUID = UUID(), name: String, address: String, operationalHours: String, acceptedDonationTypes: String, coordinate: CLLocationCoordinate2D, distance: CLLocationDistance? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.operationalHours = operationalHours
        self.acceptedDonationTypes = acceptedDonationTypes
        self.coordinate = coordinate
        self.distance = distance
    }

    static func < (lhs: DonationCenter, rhs: DonationCenter) -> Bool {
            guard let lhsDistance = lhs.distance, let rhsDistance = rhs.distance else { return false }
            return lhsDistance < rhsDistance
        }

        static func == (lhs: DonationCenter, rhs: DonationCenter) -> Bool {
            lhs.id == rhs.id
        }
}
