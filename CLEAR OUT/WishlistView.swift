//
//  WishlistView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.

import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlistManager: WishlistManager

    var body: some View {
        NavigationView {
            VStack {
                Text("My Wishlist")
                    .font(.headline)
                    .padding()

                if wishlistManager.wishlistItems.isEmpty {
                    Text("Your wishlist is empty.\nStart exploring now!")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemBackground))
                } else {
                    List {
                        ForEach(wishlistManager.wishlistItems) { item in
                            NavigationLink(destination: ItemCustomerView(item: item).environmentObject(wishlistManager)) {
                                HStack {
                                    AsyncImage(url: URL(string: item.mediaUrl)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fill).frame(width: 60, height: 60).cornerRadius(10)
                                        case .failure(_), .empty:
                                            Image(systemName: "photo").frame(width: 60, height: 60).background(Color.gray.opacity(0.1)).cornerRadius(10)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.trailing, 8)

                                    VStack(alignment: .leading) {
                                        Text(item.name).font(.headline)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .onDelete(perform: removeItems)
                    }
                }

                Spacer()
            }
        }
    }

    func removeItems(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = wishlistManager.wishlistItems[index]
            wishlistManager.removeFromWishlist(item: item)
        }
    }
}

struct WishlistView_Previews: PreviewProvider {
    static var previews: some View {
        WishlistView().environmentObject(WishlistManager.shared)
    }
}
