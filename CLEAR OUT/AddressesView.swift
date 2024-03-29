//
//  AddressesView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/26/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddressesView: View {
    @State private var addresses: [UserAddress] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(addresses.indices, id: \.self) { index in
                    AddressCardView(address: addresses[index])
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .onAppear {
            fetchAddresses()
        }
        .navigationTitle("Your Addresses")
    }

    private func fetchAddresses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("addresses").getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.addresses = querySnapshot.documents.compactMap { document -> UserAddress? in
                    let data = document.data()
                    return UserAddress(
                        name: data["name"] as? String ?? "",
                        phoneNumber: data["phoneNumber"] as? String ?? "",
                        addressLine1: data["addressLine1"] as? String ?? "",
                        addressLine2: data["addressLine2"] as? String ?? "",
                        city: data["city"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        zipCode: data["zipCode"] as? String ?? "",
                        country: data["country"] as? String ?? ""
                    )
                }
            } else {
                print("Error fetching addresses: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
}

struct AddressCardView: View {
    var address: UserAddress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !address.name.isEmpty {
                Text(address.name).bold().font(.headline)
            }
            if !address.addressLine1.isEmpty || !address.addressLine2.isEmpty {
                Divider()
                HStack {
                    Image(systemName: "house.fill").foregroundColor(.secondary)
                    Text([address.addressLine1, address.addressLine2].compactMap { $0.isEmpty ? nil : $0 }.joined(separator: ", "))
                }
            }
            if !address.city.isEmpty || !address.state.isEmpty || !address.zipCode.isEmpty {
                HStack {
                    Image(systemName: "mappin.circle.fill").foregroundColor(.secondary)
                    Text([address.city, address.state, address.zipCode].compactMap { $0.isEmpty ? nil : $0 }.joined(separator: ", "))
                }
            }
            if !address.phoneNumber.isEmpty {
                HStack {
                    Image(systemName: "phone.fill").foregroundColor(.secondary)
                    Text(address.phoneNumber)
                }
            }
            if !address.country.isEmpty {
                HStack {
                    Image(systemName: "globe").foregroundColor(.secondary)
                    Text(address.country)
                }
            }
        }
        .padding()
        .background(Color.white) // Changed background color to match NotificationCardView
        .cornerRadius(10)
        .shadow(radius: 5) // Adjusted shadow to match NotificationCardView
        .padding(.vertical, 5) // Added vertical padding to each card
    }
}



// Ensure you have a UserAddress struct that matches your data structure
struct UserAddress: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let addressLine1: String
    let addressLine2: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
}

struct AddressesView_Previews: PreviewProvider {
    static var previews: some View {
        AddressesView()
    }
}
