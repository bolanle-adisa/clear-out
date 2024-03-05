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
    @EnvironmentObject var wishlistManager: WishlistManager

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
            
//                .onAppear {
//                    print("WishlistManager is accessible in ItemCard")
//                }

            HStack {
                Button(action: {
                    print("Wishlist add button tapped for item: \(item.name)") // Debug message
                    self.wishlistManager.addToWishlist(item: self.item)
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)

                Button(action: {
                    // Add to cart action
                }) {
                    Image(systemName: "cart")
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
