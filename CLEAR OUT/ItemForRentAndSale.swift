//
//  ItemForRentAndSale.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemForSaleAndRent: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var price: Double?
    var size: String?
    var color: String?
    var mediaUrl: String
    var isVideo: Bool
    var rentPrice: Double?
    var rentPeriod: String?
    var userId: String
    @ServerTimestamp var timestamp: Date?
    var sold: Bool?
}
