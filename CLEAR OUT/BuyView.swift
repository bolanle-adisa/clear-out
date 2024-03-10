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
    @State private var selectedOption: String? = nil
    @State private var itemsForSaleAndRent: [ItemForSaleAndRent] = []
    @State private var filteredItems: [ItemForSaleAndRent] = []
    @StateObject private var itemsManager = ItemsForSaleManager()
    @EnvironmentObject var cartManager: CartManager
    @State private var showingWishlistView = false
    @EnvironmentObject var wishlistManager: WishlistManager

    let options = ["Dorm Essentials", "Books", "Women's Clothes", "Men's Clothes", "Women's Shoes", "Men's Shoes", "Electronics"]

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
                self.fetchItemsForSale()
            }
            self.fetchItemsForSale()
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
                print("Wishlist button tapped") // Debug message
                showingWishlistView = true
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.black)
                    .imageScale(.large)
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
                ForEach(displayItems) { item in
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

    private func fetchItemsForSale() {
        let db = Firestore.firestore()
        db.collection("itemsForSaleAndRent").getDocuments { (querySnapshot, err) in // Updated collection name
            if let err = err {
                print("Error getting documents: \(err)(BuyView)")
            } else if let querySnapshot = querySnapshot {
                print("Successfully fetched \(querySnapshot.documents.count) items(BuyView)")
                var mappedItems: [ItemForSaleAndRent] = []
                for document in querySnapshot.documents {
                    do {
                        let item = try document.data(as: ItemForSaleAndRent.self)
                        mappedItems.append(item)
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
            }
        }
    }
    
    private func filterItems() {
            if searchText.isEmpty {
                filteredItems = itemsForSaleAndRent
            } else {
                let lowercasedQuery = searchText.lowercased()
                filteredItems = itemsForSaleAndRent.filter { item in
                    item.name.lowercased().contains(lowercasedQuery) ||
                    (item.description?.lowercased().contains(lowercasedQuery) ?? false)
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
    }
}
