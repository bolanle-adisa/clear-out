//
//  SignInView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    var email: String
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showingResetPasswordAlert = false
    @EnvironmentObject var userSession: UserSession
    @Binding var showingProfile: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("SIGN IN")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                
                Text(email)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    signInUser(email: email, password: password)
                }) {
                    Text("Continue")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button("Forgot Password?") {
                    resetPassword(for: email)
                }
                .foregroundColor(.black)
                .padding()
                .alert(isPresented: $showingResetPasswordAlert) {
                    Alert(
                        title: Text("Reset Password"),
                        message: Text("A link to reset your password has been sent to \(email)"),
                        dismissButton: .default(Text("OK"))
                    )
                }

                Spacer()
            }
        }
        .onAppear {
            fetchFirstName()
        }
    }
    
    private func resetPassword(for email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.showingResetPasswordAlert = true
            }
        }
    }

    private func fetchFirstName() {
        // Fetch the first name from Firestore or your desired data source
        // Update userSession.firstName accordingly
    }

    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    self.userSession.isAuthenticated = true
                    self.showingProfile = false // Dismiss the view
                }
            }
        }
    }
}

// Preview
struct SignInView_Previews: PreviewProvider {
    // Create a State variable for the preview to simulate the binding
    @State static var previewShowingProfile = false

    static var previews: some View {
        // Pass the binding to the preview
        SignInView(email: "test@example.com", showingProfile: $previewShowingProfile)
            .environmentObject(UserSession())  // Ensure to add this if your view relies on UserSession
    }
}
