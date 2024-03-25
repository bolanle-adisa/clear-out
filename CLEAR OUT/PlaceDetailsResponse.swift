//
//  PlaceDetailsResponse.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/24/24.
//

import Foundation
struct PlaceDetailsResponse: Decodable {
    let result: PlaceDetails?
}

struct PlaceDetails: Decodable {
    let name: String
    let formattedAddress: String
    let streetAddress: String
    let subpremise: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case formattedAddress = "formatted_address"
        case addressComponents = "address_components"
    }
    
    enum AddressComponentType: String, Decodable {
        case streetNumber = "street_number"
        case route
        case subpremise
        case locality
        case administrativeAreaLevel1 = "administrative_area_level_1"
        case postalCode = "postal_code"
        case country
    }
    
    struct AddressComponent: Decodable {
        let types: [AddressComponentType]
        let longName: String?
        let shortName: String?
        
        enum CodingKeys: String, CodingKey {
            case types
            case longName = "long_name"
            case shortName = "short_name"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        formattedAddress = try container.decode(String.self, forKey: .formattedAddress)
        
        let addressComponents = try container.decode([AddressComponent].self, forKey: .addressComponents)
        
        streetAddress = addressComponents.first { $0.types.contains(.streetNumber) }?.longName ?? ""
        subpremise = addressComponents.first { $0.types.contains(.subpremise) }?.longName ?? ""
        city = addressComponents.first { $0.types.contains(.locality) }?.longName ?? ""
        state = addressComponents.first { $0.types.contains(.administrativeAreaLevel1) }?.shortName ?? ""
        zipCode = addressComponents.first { $0.types.contains(.postalCode) }?.longName ?? ""
        country = addressComponents.first { $0.types.contains(.country) }?.longName ?? ""
    }
}
