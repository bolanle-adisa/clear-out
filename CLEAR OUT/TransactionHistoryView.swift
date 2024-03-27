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
    @State private var selectedToggle = 0
    
    let toggleOptions = ["Sold Items", "Bought Items"]
    
    var body: some View {
        VStack {
            Picker("Toggle Options", selection: $selectedToggle) {
                ForEach(0..<toggleOptions.count) { index in
                    Text(self.toggleOptions[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(selectedToggle == 0 ? soldItems : purchasedItems) { item in
                        TransactionCardView(item: item, isSold: selectedToggle == 0)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
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
}

    struct TransactionCardView: View {
        var item: ItemForSaleAndRent
        var isSold: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: isSold ? "tag.fill" : "cart.fill")
                        .foregroundColor(isSold ? .blue : .blue)
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    if let timestamp = item.timestamp {
                        Text(formattedDate(timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Price: $\(item.price ?? 0, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(isSold ? .green : .red)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.vertical, 5)
        }
        
        private func formattedDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
    }

struct TransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TransactionHistoryView()
        }
    }
}
