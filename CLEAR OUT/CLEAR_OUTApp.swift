//
//  CLEAR_OUTApp.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct CLEAR_OUTApp: App {
    @StateObject var userSession = UserSession()
    @StateObject var cartManager = CartManager.shared

    init() {
        FirebaseApp.configure()
        // Initial authentication state set here, but dynamic changes are handled in ContentView
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession)
                .environmentObject(cartManager)
                .environmentObject(WishlistManager.shared)
        }
    }
}
