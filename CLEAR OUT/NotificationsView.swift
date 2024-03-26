//
//  NotificationsView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/26/24.
//

import SwiftUI

import SwiftUI

struct NotificationsView: View {
    var notifications: [UserNotification]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(notifications) { notification in
                    NotificationCardView(notification: notification)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .navigationTitle("Notifications")
    }
}

struct NotificationCardView: View {
    var notification: UserNotification

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "bell.fill") // Example icon, change as needed
                    .foregroundColor(.blue)
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(notification.timestamp, formatter: DateFormatter.shortDateShortTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(notification.message)
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.vertical, 5)
    }
}

extension DateFormatter {
    static let shortDateShortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create some sample notifications to display in the preview
        let sampleNotifications = [
            UserNotification(id: "1", title: "Welcome!", message: "Thanks for joining our app.", timestamp: Date(), read: false),
            UserNotification(id: "2", title: "Order Shipped", message: "Your order has shipped.", timestamp: Date().addingTimeInterval(-86400), read: false), // 1 day ago
            UserNotification(id: "3", title: "Payment Received", message: "We've received your payment.", timestamp: Date().addingTimeInterval(-172800), read: false) // 2 days ago
        ]
        
        // Return the NotificationsView with the sample data
        NotificationsView(notifications: sampleNotifications)
    }
}
