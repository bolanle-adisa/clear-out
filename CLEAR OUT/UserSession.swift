//
//  UserSession.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import Foundation

import SwiftUI

class UserSession: ObservableObject {
    // Add properties here to represent the user's session
    // For example, a simple isLoggedIn flag:
    @Published var isLoggedIn: Bool = false
    @Published var isAuthenticated = false
    @Published var firstName: String = ""

    // Add more properties and methods as needed
    
    func authenticateUser() {
            isAuthenticated = true
        }
}
