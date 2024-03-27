//
//  TransactionHistoryView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/26/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TransactionHistoryView: View {
    @State private var soldItems: [ItemForSaleAndRent] = []
    
    var body: some View {
        List(soldItems) { item in
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                Text("Price: $\(item.price ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                
                Text("Sold on: \(item.timestamp ?? Date(), formatter: itemDateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Transaction History")
        .onAppear(perform: fetchSoldItems)
    }
    
    private func fetchSoldItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent")
            .whereField("userId", isEqualTo: userId)
            .whereField("sold", isEqualTo: true)
            .order(by: "soldTimestamp", descending: true)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching sold items: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No sold items found")
                    return
                }
                
                print("Fetched \(documents.count) sold items") // Debugging statement
                
                self.soldItems = documents.compactMap { document -> ItemForSaleAndRent? in
                    try? document.data(as: ItemForSaleAndRent.self)
                }
                
                print("Mapped \(self.soldItems.count) sold items") // Debugging statement
            }
    }
}
