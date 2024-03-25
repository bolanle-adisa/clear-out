//
//  CartManager.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation

class CartManager: ObservableObject {
    static let shared = CartManager()
    @Published var cartItems: [CartItem] = []
    
    private init() {}
    
    enum CartOption {
        case sell
        case rent
    }
    
    struct CartItem: Identifiable {
        let item: ItemForSaleAndRent
        let option: CartOption
        var price: Double {
            switch option {
            case .sell:
                return item.price ?? 0.0
            case .rent:
                return item.rentPrice ?? 0.0
            }
        }
        var id: String { item.id ?? "defaultID" }
    }

    func addToCart(item: ItemForSaleAndRent, option: CartOption) {
        let cartItem = CartItem(item: item, option: option)
        cartItems.append(cartItem)
        print("Item added to cart. Total items now: \(cartItems.count)")
    }
    
    func removeFromCart(itemID: String) {
        if let index = cartItems.firstIndex(where: { $0.id == itemID }) {
            cartItems.remove(at: index)
            print("Item removed. Total items now: \(cartItems.count)")
        } else {
            print("Item to remove not found in cart. Item ID: \(itemID)")
        }
    }
    
    func clearCart() {
        cartItems.removeAll() // Clears all items from the cart
    }


    // Include any other existing methods or logic you have in this class
}
