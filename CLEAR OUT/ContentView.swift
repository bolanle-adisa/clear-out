//
//  ContentView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var cartManager: CartManager
    @State private var selectedTab = 0
    @State private var showingProfile = false

    var body: some View {
        TabView(selection: $selectedTab) {
            BuyView()
                .environmentObject(CartManager.shared)
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
                .tag(0)

            SellView()
                .environmentObject(userSession)
                .tabItem {
                    Label("Sell", systemImage: "tag.fill")
                }
                .tag(1)
            
            CartView()
                .environmentObject(CartManager.shared)
                .tabItem {
                    // Custom tab item with badge
                    VStack {
                        if cartManager.cartItems.count > 0 {
                            Text("\(cartManager.cartItems.count)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        }
                        Image(systemName: "cart.fill")
                        Text("Cart")
                    }
                }
                .tag(2)

            DonateView()
                .tabItem {
                    Label("Donate", systemImage: "gift.fill")
                }
                .tag(3)

            Group {
                if userSession.isAuthenticated {
                    UserProfileTwoView()
                } else {
                    UserProfileView(showingProfile: $showingProfile) // Pass the binding here
                        .environmentObject(userSession)
                }
            }
            .tabItem {
                Label("Me", systemImage: "person.crop.circle.fill")
            }
            .tag(4)
        }
        .onReceive(userSession.$isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                selectedTab = 4
            }
        }
        .preferredColorScheme(.light)
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession())
            .environmentObject(CartManager.shared)
            .environmentObject(WishlistManager.shared)
    }
}
