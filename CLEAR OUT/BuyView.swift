//
//  BuyView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI

import FirebaseFirestore
import AVKit

struct BuyView: View {
    @State private var searchText = ""
    @State private var isCameraPresented = false
    @State private var selectedOption: String? = "All"
    @State private var itemsForSaleAndRent: [ItemForSaleAndRent] = []
    @State private var filteredItems: [ItemForSaleAndRent] = []
    @StateObject private var itemsManager = ItemsForSaleManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var showingWishlistView = false
    @EnvironmentObject var wishlistManager: WishlistManager

    let options = ["All", "Dorm Essentials", "Books", "Women's Clothes", "Men's Clothes", "Shoes", "Electronics"]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                titleAndWishListIcon
                searchBar
                optionsGroup
                itemsGrid
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingWishlistView) {
                WishlistView().environmentObject(WishlistManager.shared)
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            Text("Camera Functionality Here")
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("DidAddNewItem"), object: nil, queue: .main) { _ in
                self.fetchItemsForSale() {
                    self.filterItems()
                }
            }
            self.fetchItemsForSale() {
                self.filterItems()
            }
        }
        .onChange(of: searchText) { newValue in
            filterItems()
        }
        .onChange(of: selectedOption) { _ in
            filterItems()
        }

    }

    var titleAndWishListIcon: some View {
        HStack {
                Text("CLEAROUT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    print("Wishlist button tapped")
                    showingWishlistView = true
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.black)
                            .imageScale(.large)
                        
                        // Only show the count badge if there are items in the wishlist
                        if wishlistManager.wishlistItems.count > 0 {
                            Text("\(wishlistManager.wishlistItems.count)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 12, y: -10)
                        }
                    }
                }
                .padding(.trailing, 15)
            }
            .padding(.leading)
        }

    var searchBar: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(9)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(searchOverlayView)
        }
        .padding([.leading, .trailing])
    }

    var searchOverlayView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            Spacer()
            
            if !searchText.isEmpty {
                Button(action: {
                    self.searchText = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: {
                self.isCameraPresented = true
            }) {
                Image(systemName: "camera.viewfinder")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
    }

    var optionsGroup: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        self.selectedOption = option
                    }) {
                        Text(option)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(self.selectedOption == option ? LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) : LinearGradient(gradient: Gradient(colors: [Color.white]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(self.selectedOption == option ? .white : .black)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: self.selectedOption == option ? 0 : 1))
                            .shadow(color: self.selectedOption == option ? Color.blue.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding(.vertical)
        }
        .padding(.leading)
    }

    var itemsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
        
        let displayItems = searchText.isEmpty ? itemsForSaleAndRent : filteredItems
        
        return ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredItems) { item in
                    NavigationLink(destination: ItemCustomerView(item: item)) {
                        ItemCard(item: item)
                            .environmentObject(wishlistManager)
                    }
                }
            }
            .padding([.horizontal, .top])
        }
        .background(Color(.systemGray6)) // Set background color for the scrollable part
    }

    private func fetchItemsForSale(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)(BuyView)")
                    completion()
                } else if let querySnapshot = querySnapshot {
                    print("Successfully fetched \(querySnapshot.documents.count) items(BuyView)")
                    var mappedItems: [ItemForSaleAndRent] = []
                    for document in querySnapshot.documents {
                        do {
                            var item = try document.data(as: ItemForSaleAndRent.self)
                            
                            // Check if the 'sold' field exists, and if it's false or doesn't exist, add the item
                            if let sold = document.data()["sold"] as? Bool, !sold {
                                mappedItems.append(item)
                            } else if document.data()["sold"] == nil {
                                // If the 'sold' field doesn't exist, assume it's not sold and add the item
                                mappedItems.append(item)
                            }
                        } catch {
                            print("Failed to map document to ItemForSaleAndRent: \(error)(BuyView)")
                        }
                    }
                    self.itemsForSaleAndRent = mappedItems
                    if self.itemsForSaleAndRent.isEmpty {
                        print("ItemsForSaleAndRent is empty after fetch(BuyView).")
                    } else {
                        print("Mapped \(self.itemsForSaleAndRent.count) items successfully(BuyView).")
                    }
                    completion()
                }
            }
    }
    
    private func filterItems() {
        if searchText.isEmpty && (selectedOption == "All" || selectedOption == nil) {
            filteredItems = itemsForSaleAndRent
        } else if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            filteredItems = itemsForSaleAndRent.filter { item in
                item.name.lowercased().contains(lowercasedQuery) ||
                (item.description?.lowercased().contains(lowercasedQuery) ?? false)
            }
        } else {
            switch selectedOption {
            case "Dorm Essentials":
                // Show hard-coded items for Books
                filteredItems = [
                    ItemForSaleAndRent(id: "13", name: "Bedding Set", description: "A comfortable and cozy bedding set", price: 80.0, size: "Twin XL", color: "Gray", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "14", name: "Desk Lamp", description: "A stylish and functional desk lamp", price: 25.0, size: nil, color: "Black", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "15", name: "Mini Fridge", description: "A compact refrigerator for dorm rooms", price: 150.0, size: "3.2 cu ft", color: "Stainless Steel", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "16", name: "Laundry Hamper", description: "A collapsible laundry hamper for easy storage", price: 15.0, size: nil, color: "Blue", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "17", name: "Shower Caddy", description: "A portable shower caddy for dorm bathrooms", price: 10.0, size: nil, color: "Pink", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "18", name: "Storage Bins", description: "A set of stackable storage bins", price: 30.0, size: "Medium", color: "Clear", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            case "Books":
                // Show hard-coded items for Books
                filteredItems = [
                    ItemForSaleAndRent(id: "1", name: "Book 1", description: "A book about programming", price: 10.0, size: nil, color: nil, mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "2", name: "Book 2", description: "A book about design", price: 15.0, size: nil, color: nil, mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            case "Women's Clothes":
                // Show hard-coded items for Women's Clothes
                filteredItems = [
                    ItemForSaleAndRent(id: "3", name: "Dress", description: "A beautiful dress", price: 50.0, size: "M", color: "Red", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "4", name: "Blouse", description: "A stylish blouse", price: 30.0, size: "S", color: "Blue", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            case "Men's Clothes":
                // Show hard-coded items for Men's Clothes
                filteredItems = [
                    ItemForSaleAndRent(id: "5", name: "Shirt", description: "A casual shirt", price: 25.0, size: "L", color: "White", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "6", name: "Jeans", description: "A pair of jeans", price: 40.0, size: "32", color: "Blue", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            case "Shoes":
                // Show hard-coded items for Shoes
                filteredItems = [
                    ItemForSaleAndRent(id: "7", name: "Heels", description: "A pair of high heels", price: 80.0, size: "7", color: "Black", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "8", name: "Sneakers", description: "Comfortable sneakers", price: 60.0, size: "8", color: "White", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "9", name: "Loafers", description: "Stylish loafers", price: 70.0, size: "9", color: "Brown", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "10", name: "Boots", description: "Durable boots", price: 90.0, size: "10", color: "Black", mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            case "Electronics":
                // Show hard-coded items for Electronics
                filteredItems = [
                    ItemForSaleAndRent(id: "11", name: "Smartphone", description: "A powerful smartphone", price: 500.0, size: nil, color: nil, mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false),
                    ItemForSaleAndRent(id: "12", name: "Laptop", description: "A high-performance laptop", price: 1000.0, size: nil, color: nil, mediaUrl: "", isVideo: false, rentPrice: nil, rentPeriod: nil, userId: "", sold: false)
                ]
            default:
                // If none of the options match, show all items
                filteredItems = itemsForSaleAndRent
            }
        }
    }
}

struct VideoPreview: View {
    let url: URL?
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url ?? URL(string: "about:blank")!))
            .frame(width: 150, height: 150)
    }
}

struct BuyView_Previews: PreviewProvider {
    static var previews: some View {
        BuyView()
            .environmentObject(WishlistManager.shared)
            .environmentObject(UserSession())
            .environmentObject(CartManager.shared)
    }
}
