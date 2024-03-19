//
//  CLEAR_OUTApp.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Stripe

@main
struct CLEAR_OUTApp: App {
    @StateObject var userSession = UserSession()
    @StateObject var cartManager = CartManager.shared

    init() {
        FirebaseApp.configure()
        // Initial authentication state set here, but dynamic changes are handled in ContentView
        
        STPAPIClient.shared.publishableKey = "pk_test_51OtjS8FiX8jofvyhsTEfpBfp8tq5fq9miKuFqY4W4NlpFRp4xiPDJl1C2N791hjJxt8yuqY6ddZk2QxfYBuNAHuR00kiT73LwJ"
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
