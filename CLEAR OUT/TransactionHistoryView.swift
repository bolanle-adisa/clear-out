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
    @State private var purchasedItems: [ItemForSaleAndRent] = []
    
    var body: some View {
        List {
            Section(header: Text("Sold Items")) {
                ForEach(soldItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        
                        Text("Price: $\(item.price ?? 0, specifier: "%.2f")")
                            .font(.subheadline)
                        
                        if let timestamp = item.timestamp {
                            Text("Sold on: \(formattedDate(timestamp))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Section(header: Text("Bought Items")) {
                ForEach(purchasedItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        
                        Text("Price: $\(item.price ?? 0, specifier: "%.2f")")
                            .font(.subheadline)
                        
                        if let timestamp = item.timestamp {
                            Text("Purchased on: \(formattedDate(timestamp))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Transaction History")
        .onAppear {
            fetchSoldItems()
            fetchPurchasedItems()
        }
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
    
    private func fetchPurchasedItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("purchasedItems")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching purchased items: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No purchased items found")
                    return
                }
                
                self.purchasedItems = documents.compactMap { document -> ItemForSaleAndRent? in
                    try? document.data(as: ItemForSaleAndRent.self)
                }
            }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
