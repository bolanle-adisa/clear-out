//
// ChatView.swift
// CLEAR OUT
//
// Created by Bolanle Adisa on 3/28/24.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Chat messages area
            ScrollView {
                VStack(spacing: 10) {
                    // Example of a received message bubble
                    HStack {
                        Text("Order Received!")
                            .padding()
                            .foregroundColor(Color.white)
                            .background(Color.black)
                            .cornerRadius(15)
                        Spacer()
                    }
                    .padding()
                    
                    // More messages would go here
                }
            }
            .background(Color.white)

            // Bottom input field and send button
            HStack {
                TextField("Send a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline) // Set the title to inline
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Chat") // The main title
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("0.7 mi  Huston-Tillotson University") // Subtitle
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    func sendMessage() {
        // Handle sending the message
        print("Sending message: \(messageText)")
        messageText = ""
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MessagesView()
        }
    }
}
