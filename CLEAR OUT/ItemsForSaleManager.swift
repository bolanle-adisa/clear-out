//
//  ItemsForSaleManager.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift // Import FirebaseFirestoreSwift for Codable support

class ItemsForSaleManager: ObservableObject {
    @Published var itemsForSaleAndRent: [ItemForSaleAndRent] = []

    func fetchItemsForSaleAndRent() {
        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent").getDocuments { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if let querySnapshot = querySnapshot {
                print("Successfully fetched \(querySnapshot.documents.count) items")
                DispatchQueue.main.async {
                    self?.itemsForSaleAndRent = querySnapshot.documents.compactMap { document -> ItemForSaleAndRent? in
                        try? document.data(as: ItemForSaleAndRent.self)
                    }
                }
            }
        }
    }
}
