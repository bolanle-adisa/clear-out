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
    
    @State private var showingOptions = false
    
    var isInWishlist: Bool {
        wishlistManager.wishlistItems.contains(where: { $0.id == item.id })
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
                    if isInWishlist {
                        wishlistManager.removeFromWishlist(item: item)
                    } else {
                        wishlistManager.addToWishlist(item: item)
                    }
                }) {
                    Image(systemName: isInWishlist ? "heart.fill" : "heart")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)

                Button(action: {
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
                }) {
                    Image(systemName: "cart")
                        .foregroundColor(.black)
                }
                .actionSheet(isPresented: $showingOptions) {
                    actionSheetOptions()
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
