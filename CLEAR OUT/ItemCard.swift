//
//  ItemCard.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation
import SwiftUI

struct ItemCard: View {
    let item: ItemForSaleAndRent
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var wishlistManager: WishlistManager
    @EnvironmentObject var userSession: UserSession
    @State private var showLoginAlert = false
    @State private var showLoginAlert2 = false
    
    @State private var showingOptions = false
    
    var isInWishlist: Bool {
        wishlistManager.wishlistItems.contains(where: { $0.id == item.id })
    }
    
    var isInCart: Bool {
        cartManager.cartItems.contains(where: { $0.item.id == item.id })
    }
    
    var hasBothOptions: Bool {
        (item.price ?? 0) > 0 && (item.rentPrice ?? 0) > 0
    }

    var body: some View {
        VStack {
            if item.isVideo {
                VideoPreview(url: URL(string: item.mediaUrl))
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipped()
            } else {
                AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                            .clipped()
                    case .failure(_), .empty:
                        Color.gray.opacity(0.1)
                            .frame(width: 150, height: 200)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                if let salePrice = item.price, salePrice > 0 {
                                    Text("Sale: $\(salePrice, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Sale: Not Applicable")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                // Display rent price and period if available
                                if let rentPrice = item.rentPrice, rentPrice > 0, let rentPeriod = item.rentPeriod, rentPeriod != "Not Applicable" {
                                    Text("Rent: $\(rentPrice, specifier: "%.2f") / \(rentPeriod)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else if let rentPrice = item.rentPrice, rentPrice == 0 {
                                    Text("Rent: Not Applicable")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            
            HStack {
                Button(action: {
                    print("Wishlist add button tapped for item: \(item.name)")
                    if userSession.isAuthenticated {
                        if isInWishlist {
                            wishlistManager.removeFromWishlist(item: item)
                        } else {
                            wishlistManager.addToWishlist(item: item)
                        }
                    } else {
                        // Show an alert to prompt the user to login
                        showLoginAlert = true
                    }
                }) {
                    Image(systemName: isInWishlist ? "heart.fill" : "heart")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)
                .alert(isPresented: $showLoginAlert) {
                    Alert(
                        title: Text("Login Required"),
                        message: Text("Please login to add items to your wishlist."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Button(action: {
                    if userSession.isAuthenticated {
                        // Trigger the options only if both buy and rent options are available
                        if hasBothOptions {
                            showingOptions = true
                        } else {
                            // If only one option is available, directly add to cart
                            if let price = item.price, price > 0 {
                                cartManager.addToCart(item: item, option: .sell)
                            } else if let rentPrice = item.rentPrice, rentPrice > 0 {
                                cartManager.addToCart(item: item, option: .rent)
                            }
                        }
                    } else {
                        // Show an alert to prompt the user to login
                        showLoginAlert2 = true
                    }
                }) {
                    Image(systemName: isInCart ? "cart.fill" : "cart")
                        .foregroundColor(.black)
                }
                .actionSheet(isPresented: $showingOptions) {
                    actionSheetOptions()
                }
                .alert(isPresented: $showLoginAlert2) {
                    Alert(
                        title: Text("Login Required"),
                        message: Text("Please login to add items to your cart."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    func actionSheetOptions() -> ActionSheet {
            var buttons: [ActionSheet.Button] = []
            
            // Add Buy option if available
            if let price = item.price, price > 0 {
                buttons.append(.default(Text("Buy for $\(price, specifier: "%.2f")")) {
                    cartManager.addToCart(item: item, option: .sell)
                })
            }
            
            // Add Rent option if available
            if let rentPrice = item.rentPrice, rentPrice > 0 {
                buttons.append(.default(Text("Rent for $\(rentPrice, specifier: "%.2f")")) {
                    cartManager.addToCart(item: item, option: .rent)
                })
            }
            
            // Cancel button
            buttons.append(.cancel())
            
            return ActionSheet(title: Text("Select Option"), message: nil, buttons: buttons)
        }
}
