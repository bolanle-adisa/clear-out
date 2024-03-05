//
//  UserProfileView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import FirebaseFirestore

struct UserProfileView: View {
    @State private var emailAddress: String = ""
    @State private var showSignUpView: Bool = false
    @State private var showSignInView: Bool = false
    @State private var emailErrorMessage: String?
    @EnvironmentObject var userSession: UserSession
    @Binding var showingProfile: Bool

    var body: some View {
        VStack {
            Text("SIGN IN OR CREATE ACCOUNT")
                .font(.headline)
                .fontWeight(.bold)
                .padding()

            TextField("Email address", text: $emailAddress)
                .padding(9)
                .padding(.horizontal, 30)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(emailOverlayView)
                .padding()

            if let emailErrorMessage = emailErrorMessage {
                Text(emailErrorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }

            Button(action: {
                if isEmailValid(email: emailAddress) {
                    emailErrorMessage = nil
                    checkUserAccount(email: emailAddress) { exists in
                        if exists {
                            self.showSignInView = true
                            self.showSignUpView = false
                        } else {
                            self.showSignUpView = true
                            self.showSignInView = false
                        }
                    }
                } else {
                    emailErrorMessage = "Please enter a valid email address."
                }
            }) {
                Text("Continue")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            .sheet(isPresented: $showSignUpView) {
                SignUpView(email: emailAddress, showingProfile: $showingProfile)
                    .environmentObject(userSession)
            }
            .sheet(isPresented: $showSignInView) {
                SignInView(email: emailAddress, showingProfile: $showingProfile)
                    .environmentObject(userSession)
            }

            List {
                SettingRow(icon: "questionmark.circle", title: "Help Center")
                SettingRow(icon: "gearshape", title: "Settings")
            }

            Spacer() // Pushes everything to the top
        }
    }

    private func checkUserAccount(email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                let userExists = querySnapshot!.documents.count > 0
                completion(userExists)
            }
        }
    }

    private func isEmailValid(email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email)
    }

    var emailOverlayView: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.gray)
                .padding(.leading, 8)

            Spacer()

            if !emailAddress.isEmpty {
                Button(action: {
                    self.emailAddress = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct SettingRow: View {
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
            Image(systemName: "chevron.right")
        }
        .padding()
    }
}

struct UserProfileView_Previews: PreviewProvider {
    @State static var dummyShowingProfile = false

    static var previews: some View {
        UserProfileView(showingProfile: $dummyShowingProfile)
            .environmentObject(UserSession())
    }
}
