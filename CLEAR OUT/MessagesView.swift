//
// MessagesView.swift
// CLEAR OUT
//
// Created by Bolanle Adisa on 3/28/24.
//

import SwiftUI

struct MessageSummary {
    let id: Int
    let userName: String
    let lastMessage: String
    let timeStamp: String
    let avatar: String // Assuming you have an avatar image name or URL here
}

struct MessagesView: View {
    // Sample data for message summaries with added avatar field
    let messages = [
        MessageSummary(id: 1, userName: "Cynthia Jime", lastMessage: "Order Received!", timeStamp: "4m", avatar: "messageicon"),
    ]

    var body: some View {
        List {
            ForEach(messages, id: \.id) { message in
                NavigationLink(destination: ChatView()) {
                    HStack(spacing: 16) {
                        // Avatar
                        Image(message.avatar)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))

                        VStack(alignment: .leading) {
                            Text(message.userName)
                                .fontWeight(.bold)
                            Text(message.lastMessage)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Time stamp and chevron
                        VStack(alignment: .trailing) {
                            Text(message.timeStamp)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(PlainListStyle()) // Removes extra separators
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessagesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessagesView()
        }
    }
}
