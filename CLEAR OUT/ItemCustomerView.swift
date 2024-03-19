//
//  ItemCustomerView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemCustomerView: View {
    let item: ItemForSaleAndRent
    @State private var showingAddToCartConfirmation = false
    @State private var showingAddToWishlistConfirmation = false
    @EnvironmentObject var cartManager: CartManager
    @State private var sellOrRentOption: CartManager.CartOption?
    @EnvironmentObject var wishlistManager: WishlistManager

    
    var isInWishlist: Bool {
            wishlistManager.wishlistItems.contains(where: { $0.id == item.id })
        }
    
    
    var body: some View {
        ScrollView {
            VStack {
                mediaSection
                    .frame(height: 300)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Item Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    detailRow(title: "Name", value: item.name, icon: "tag")
                    detailRow(title: "Description", value: item.description ?? "No description", icon: "text.alignleft")
                    detailRow(title: "Sale Price", value: item.price ?? 0 > 0 ? String(format: "$%.2f", item.price!) : "Not Applicable", icon: "dollarsign.circle")
                    detailRow(title: "Rental Price", value: item.rentPrice ?? 0 > 0 ? String(format: "$%.2f", item.rentPrice!) : "Not Applicable", icon: "dollarsign.circle")
                    detailRow(title: "Rental Period", value: item.rentPeriod != nil && item.rentPeriod != "Not Applicable" ? item.rentPeriod! : "Not Applicable", icon: "calendar")
                    detailRow(title: "Size", value: item.size ?? "N/A", icon: "ruler")
                    detailRow(title: "Color", value: item.color ?? "No color specified", icon: "paintpalette")
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                
                customerActions
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAddToCartConfirmation) {
                Alert(
                    title: Text("Success"),
                    message: Text("\(item.name) has been added to your cart"),
                    dismissButton: .default(Text("OK"))
                )
            }
        .alert(isPresented: $showingAddToWishlistConfirmation) {
            Alert(
                title: Text("Success"),
                message: Text("\(item.name) has been added to your wishlist"),
                dismissButton: .default(Text("OK"))
            )
        }

    }
    
    @ViewBuilder
    private var mediaSection: some View {
        if item.isVideo, let url = URL(string: item.mediaUrl) {
            VideoPlayerView(videoURL: url)
                .frame(height: 300)
                .cornerRadius(12)
                .aspectRatio(contentMode: .fit)
        } else if let url = URL(string: item.mediaUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .cornerRadius(12)
                case .failure(_):
                    Image(systemName: "photo")
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                default:
                    ProgressView()
                        .frame(height: 300)
                }
            }
        }
    }
    
    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
    
    private var saleOrRentSection: some View {
        Group {
            if let salePrice = item.price, let rentPrice = item.rentPrice, let rentPeriod = item.rentPeriod {
                // Both sell and rent available
                VStack {
                    Button("Sell for \(String(format: "$%.2f", salePrice))") {
                        cartManager.addToCart(item: item, option: .sell)
                    }
                    
                    Button("Rent for \(String(format: "$%.2f", rentPrice)) / \(rentPeriod)") {
                        cartManager.addToCart(item: item, option: .rent)
                    }
                }
            } else {
                // Handling for items with only one option available will be specific to your app's logic
            }
        }
    }
    
    private var customerActions: some View {
        VStack(spacing: 10) {
            // When both sale and rent options are available
            if let salePrice = item.price, salePrice > 0,
               let rentPrice = item.rentPrice, rentPrice > 0,
               let rentPeriod = item.rentPeriod {
                VStack(spacing: 10) {
                    HStack(spacing: 20) {
                        // Buy button
                        Button("Buy for \(String(format: "$%.2f", salePrice))") {
                            sellOrRentOption = .sell
                            cartManager.addToCart(item: item, option: sellOrRentOption!)
                            showingAddToCartConfirmation = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        // Rent button
                        Button("Rent for \(String(format: "$%.2f", rentPrice))") {
                            sellOrRentOption = .rent
                            cartManager.addToCart(item: item, option: sellOrRentOption!)
                            showingAddToCartConfirmation = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        Button(action: {
                            if isInWishlist {
                                wishlistManager.removeFromWishlist(item: item)
                            } else {
                                wishlistManager.addToWishlist(item: item)
                            }
                            showingAddToWishlistConfirmation = true
                        }) {
                            Image(systemName: isInWishlist ? "heart.fill" : "heart")
                                .foregroundColor(.black)
                        }
                    }
                }
            } else {
                // Only one option available (sale or rent), buttons shown side by side
                HStack(spacing: 20) {
                    if let salePrice = item.price, salePrice > 0 {
                        // Buy button for sale option
                        Button("Buy for \(String(format: "$%.2f", salePrice))") {
                            sellOrRentOption = .sell
                            cartManager.addToCart(item: item, option: sellOrRentOption!)
                            showingAddToCartConfirmation = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    else if let rentPrice = item.rentPrice, rentPrice > 0 {
                        // Rent button for rent option
                        Button("Rent for \(String(format: "$%.2f", rentPrice))") {
                            sellOrRentOption = .rent
                            cartManager.addToCart(item: item, option: sellOrRentOption!)
                            showingAddToCartConfirmation = true
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    
                    // Add to Wishlist button, shown side by side when only one option is available
                    Button(action: {
                        if isInWishlist {
                            wishlistManager.removeFromWishlist(item: item)
                        } else {
                            wishlistManager.addToWishlist(item: item)
                        }
                        showingAddToWishlistConfirmation = true
                    }) {
                        Image(systemName: isInWishlist ? "heart.fill" : "heart")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .padding(.top)
    }
}

struct ItemCustomerView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyItem = ItemForSaleAndRent(
            id: "dummyID",
            name: "Sample Item",
            description: "This is a sample item for preview.",
            price: 99.99,
            size: "M",
            color: "Red",
            mediaUrl: "http://example.com/sample.jpg",
            isVideo: false,
            rentPrice: 0, // Assuming you have a rentPrice
            rentPeriod: "Not Applicable", // Assuming you have a rentPeriod
            userId: "user123"
        )
        ItemCustomerView(item: dummyItem).environmentObject(CartManager.shared)
            .environmentObject(WishlistManager.shared)
    }
}
