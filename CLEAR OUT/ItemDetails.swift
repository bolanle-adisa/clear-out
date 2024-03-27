//
//  ItemDetails.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import FirebaseFirestoreSwift

struct ItemDetails: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var size: String
    var color: String
    var mediaUrl: String
    var isVideo: Bool
    var sellOrRent: String
    var rentPrice: Double?
    var rentPeriod: String?
    var userId: String
    @ServerTimestamp var timestamp: Date?
    var sold: Bool?
    
    init(from dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.price = dictionary["price"] as? Double ?? 0.0
        self.size = dictionary["size"] as? String ?? ""
        self.color = dictionary["color"] as? String ?? ""
        self.mediaUrl = dictionary["mediaUrl"] as? String ?? ""
        self.isVideo = dictionary["isVideo"] as? Bool ?? false
        self.sellOrRent = dictionary["sellOrRent"] as? String ?? ""
        self.rentPrice = dictionary["rentPrice"] as? Double
        self.rentPeriod = dictionary["rentPeriod"] as? String
        self.userId = dictionary["userId"] as? String ?? ""
        self.sold = dictionary["sold"] as? Bool
    }

}
