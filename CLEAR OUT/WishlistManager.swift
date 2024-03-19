//
//  WishlistManager.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation

class WishlistManager: ObservableObject {
    static let shared = WishlistManager()
    @Published var wishlistItems: [ItemForSaleAndRent] = []

    func addToWishlist(item: ItemForSaleAndRent) {
        DispatchQueue.main.async {
            self.performAddToWishlist(item: item)
        }
    }
    
    private func performAddToWishlist(item: ItemForSaleAndRent) {
        print("Attempting to add item to wishlist: \(item.name)")
        
        guard !self.wishlistItems.contains(where: { $0.id == item.id }) else {
            print("Item already in wishlist: \(item.name)")
            return
        }
        
        self.wishlistItems.append(item)
        print("Item successfully added to wishlist: \(item.name)")
        print("Completed addToWishlist method for item: \(item.name)")
    }
    
    func removeFromWishlist(item: ItemForSaleAndRent) {
        DispatchQueue.main.async {
            if let index = self.wishlistItems.firstIndex(where: { $0.id == item.id }) {
                self.wishlistItems.remove(at: index)
                print("Item removed from wishlist: \(item.name)")
            }
        }
    }

}
