//
//  WishlistView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlistManager: WishlistManager
    @State private var selectedItem: ItemForSaleAndRent?

    var body: some View {
        NavigationView {
            VStack {
                Text("My Wishlist")
                    .font(.headline)
                    .padding()

                List(wishlistManager.wishlistItems) { item in
                    VStack(alignment: .leading) {
                        Text(item.name).font(.headline)
                       
                        Text("Price: $\(item.price ?? 0.0, specifier: "%.2f")")
                       
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedItem = item
                    }
                }
                Spacer()
            }
            .sheet(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }
}


struct ItemDetailView: View {
    var item: ItemForSaleAndRent

    var body: some View {
        VStack {
            Text(item.name) // Display the item's name
            // Add more item details here as needed
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView().environmentObject(WishlistManager.shared)
    }
}
