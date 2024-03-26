//
//  UserProfileTwoView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserProfileTwoView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var firstName: String = "User"
    @State private var email: String = ""
    @State private var university: String = ""
    @State private var notifications: [UserNotification] = []


    var body: some View {
        NavigationView {
            VStack {
                Text("ACCOUNT")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hi, \(firstName)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if !email.isEmpty {
                            Text(email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        if !university.isEmpty {
                            Text(university)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer() // Pushes text to the left
                }
                .padding(.leading, 30)
                
                List {
                    SettingRowTwo(icon: "message", title: "Messages")
                    NavigationLink(destination: NotificationsView(notifications: self.notifications)) {
                        SettingRowTwo(icon: "bell", title: "Notifications")
                    }
                    SettingRowTwo(icon: "map", title: "Addresses")
                    SettingRowTwo(icon: "creditcard", title: "Payment Method")
                    SettingRowTwo(icon: "list.bullet.rectangle.portrait", title: "Transaction History")
                    SettingRowTwo(icon: "questionmark.circle", title: "Help Center")
                    SettingRowTwo(icon: "gearshape", title: "Settings")
                    
                    Button(action: logoutUser) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                Spacer() // Pushes everything to the top
            }
            .onAppear {
                fetchUserData()
            }
        }
    }
    
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found")
            return
        }
        
        let db = Firestore.firestore()
        // Fetch user data
        db.collection("users").document(userId).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.firstName = data?["firstName"] as? String ?? "User"
                self.email = data?["email"] as? String ?? ""
                self.university = data?["college"] as? String ?? "Not Specified"
                
                DispatchQueue.main.async {
                    self.userSession.firstName = self.firstName
                    self.userSession.university = self.university
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        
        // Fetch notifications
        db.collection("users").document(userId).collection("notifications").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.notifications = querySnapshot.documents.map { document -> UserNotification in
                    let data = document.data()
                    return UserNotification(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        message: data["message"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            } else {
                print("Error fetching notifications: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            userSession.isAuthenticated = false // Update your user session state here
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    struct SettingRowTwo: View {
        let icon: String
        let title: String
        let detail: String?
        
        init(icon: String, title: String, detail: String? = nil) {
            self.icon = icon
            self.title = title
            self.detail = detail
        }
        
        var body: some View {
            HStack {
                Image(systemName: icon)
                Text(title)
                Spacer()
                if let detail = detail {
                    Text(detail)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
}

struct UserProfileTwoView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileTwoView()
            .environmentObject(UserSession()) // Mock user session for preview
    }
}
