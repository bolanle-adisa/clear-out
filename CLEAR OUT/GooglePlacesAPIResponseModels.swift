//
//  GooglePlacesAPIResponseModels.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation

struct PlacesResponse: Decodable {
    let results: [Place]
}

struct Place: Decodable {
    let name: String
    let vicinity: String
    let geometry: Geometry
}

struct Geometry: Decodable {
    let location: Location
}

struct Location: Decodable {
    let lat: Double
    let lng: Double
}
