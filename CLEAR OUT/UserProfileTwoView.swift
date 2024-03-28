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
    @State private var unreadNotificationCount = 0

    let paymentMethods: [PaymentMethod] = [
        PaymentMethod(id: "1", cardBrand: "Visa", last4: "4242"),
        PaymentMethod(id: "2", cardBrand: "MasterCard", last4: "5678"),
        PaymentMethod(id: "3", cardBrand: "Amex", last4: "9012")
    ]
    
    @State private var bankAccounts: [BankAccount] = [
        // Initialize with some bank accounts...
        BankAccount(id: "1", bankName: "Chase Bank", accountNumber: "4791"),
//        BankAccount(id: "2", bankName: "Bank of America", accountNumber: "4883"),
//        // ... more bank accounts
    ]

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
                    NavigationLink(destination: MessagesView()) {
                        SettingRowTwo(icon: "message", title: "Messages")
                    }
                    NavigationLink(destination: NotificationsView(notifications: $notifications, markNotificationsAsRead: markNotificationsAsRead)) {
                        SettingRowTwo(icon: "bell", title: "Notifications", notificationCount: unreadNotificationCount)
                    }
                    NavigationLink(destination: AddressesView()) {
                        SettingRowTwo(icon: "map", title: "Addresses")
                    }
                    NavigationLink(destination: PaymentMethodsView(paymentMethods: paymentMethods, bankAccounts: bankAccounts)) {
                        SettingRowTwo(icon: "creditcard", title: "Payment Information")
                    }
                    NavigationLink(destination: TransactionHistoryView()) {
                        SettingRowTwo(icon: "list.bullet.rectangle.portrait", title: "Transaction History")
                    }
                    
                    NavigationLink(destination: HelpCenterView()) {SettingRowTwo(icon: "questionmark.circle", title: "Help Center")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        SettingRowTwo(icon: "gearshape", title: "Settings")
                    }

                    
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
                calculateUnreadNotifications()
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
                self.calculateUnreadNotifications()
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        
        // Fetch notifications
        db.collection("users").document(userId).collection("notifications").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                self.notifications = querySnapshot.documents.compactMap { document -> UserNotification? in
                    let data = document.data()
                    return UserNotification(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        message: data["message"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        read: data["read"] as? Bool ?? false
                    )
                }
                // Update the userSession.notifications property
                self.userSession.notifications = self.notifications
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
    
    private func calculateUnreadNotifications() {
        unreadNotificationCount = notifications.filter { !$0.read }.count
    }
    
    private func markNotificationsAsRead() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        // Update the 'read' field of all notifications to true
        for index in notifications.indices {
            let notification = notifications[index]
            db.collection("users").document(userId).collection("notifications").document(notification.id).updateData(["read": true]) { error in
                if let error = error {
                    print("Error marking notification as read: \(error.localizedDescription)")
                } else {
                    // Update the local notification array
                    self.notifications[index].read = true
                }
            }
        }

        // Recalculate the unread count
        calculateUnreadNotifications()
    }
    
    
    struct SettingRowTwo: View {
        let icon: String
        let title: String
        let detail: String?
        var notificationCount: Int = 0
        
        init(icon: String, title: String, detail: String? = nil, notificationCount: Int = 0) {
                self.icon = icon
                self.title = title
                self.detail = detail
                self.notificationCount = notificationCount
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
                if notificationCount > 0 {
                    Text("\(notificationCount)")
                        .font(.caption2)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
    }
}

struct UserProfileTwoView_Previews: PreviewProvider {
    static var previews: some View {
        let mockUserSession = UserSession()
        mockUserSession.firstName = "John"
        mockUserSession.university = "Example University"
        mockUserSession.notifications = [
            UserNotification(id: "1", title: "Welcome!", message: "Thanks for joining our app.", timestamp: Date(), read: false),
            UserNotification(id: "2", title: "Order Shipped", message: "Your order has shipped.", timestamp: Date().addingTimeInterval(-86400), read: true)
        ]
        
        return UserProfileTwoView()
            .environmentObject(mockUserSession)
    }
}
