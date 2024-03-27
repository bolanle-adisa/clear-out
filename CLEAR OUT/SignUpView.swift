//
//  SignUpView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    let email: String
    @State private var firstName: String = ""
        @State private var lastName: String = ""
        @State private var password: String = ""
        @State private var confirmPassword: String = ""
        @State private var passwordErrorMessage: String?
        @State private var showingPasswordCriteria = false
        @State private var showingCollegePicker = false
        @State private var collegeText: String = "College/University"
        @State private var selectedCollege: College?
        @State private var navigationActive = false
        @StateObject private var collegeFetcher = CollegeDataFetcher()
        @EnvironmentObject var userSession: UserSession
        @Environment(\.presentationMode) var presentationMode
        @Binding var showingProfile: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("CREATE ACCOUNT")
                    .font(.headline)
                    .fontWeight(.bold)
                    //.padding()
                Text(email.lowercased())
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()

                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: password) { _ in
                            showingPasswordCriteria = true
                        }

                    if showingPasswordCriteria {
                        PasswordCriteriaView(password: password)
                    }
                }

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                if let errorMessage = passwordErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Button(action: {
                    self.showingCollegePicker = true
                }) {
                    HStack {
                        Text(collegeText)
                            .foregroundColor(collegeText == "College/University" ? Color.gray : Color.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .actionSheet(isPresented: $showingCollegePicker) {
                                    ActionSheet(
                                        title: Text("Select College/University"),
                                        buttons: collegeFetcher.colleges.map { college in
                                            .default(Text(college.name)) {
                                                self.collegeText = college.name
                                                self.selectedCollege = college
                                            }
                                        } + [.cancel()]
                                    )
                                }

                Button(action: {
                                        if validatePasswords() {
                                            signUpUser()
                                        }
                                    }) {
                                        Text("Create Account")
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .padding()
                                            .background(Color.black)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                    .padding(.horizontal)

                                    NavigationLink(destination: UserProfileTwoView(), isActive: $navigationActive) {
                                        EmptyView()
                                    }
                                }
                                .padding()
                            }
                            .onAppear {
                                collegeFetcher.fetchColleges()
                            }
                        }

    private func validatePasswords() -> Bool {
        passwordErrorMessage = nil

        let passwordLengthRequirement = password.count >= 8
        let containsUpperCase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let containsLowerCase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let containsNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let containsSpecialCharacter = password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil
        let passwordsMatch = password == confirmPassword

        if !passwordLengthRequirement {
            passwordErrorMessage = "Password must be at least 8 characters long."
        } else if !containsUpperCase {
            passwordErrorMessage = "Password must contain an uppercase letter."
        } else if !containsLowerCase {
            passwordErrorMessage = "Password must contain a lowercase letter."
        } else if !containsNumber {
            passwordErrorMessage = "Password must contain a number."
        } else if !containsSpecialCharacter {
            passwordErrorMessage = "Password must contain a special character."
        } else if !passwordsMatch {
            passwordErrorMessage = "Passwords do not match."
        }

        return passwordErrorMessage == nil
    }
    
    private func signUpUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.passwordErrorMessage = error.localizedDescription
            } else if let userId = authResult?.user.uid {
                let db = Firestore.firestore()
                // Set user data
                let userData: [String: Any] = [
                    "firstName": self.firstName,
                    "lastName": self.lastName,
                    "email": self.email,
                    "college": self.selectedCollege?.name ?? "Not Specified"
                    // Add other fields if necessary
                ]
                
                db.collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        print("Error writing user document: \(error)")
                        self.passwordErrorMessage = "Failed to save user data."
                    } else {
                        
                        let initialNotification: [String: Any] = [
                            "title": "Welcome to ClearOut!",
                            "message": "Your account has been successfully created.",
                            "timestamp": Timestamp(date: Date()),
                            "read": false
                        ]
                        
                        db.collection("users").document(userId).collection("notifications").addDocument(data: initialNotification) { error in
                            if let error = error {
                                print("Error adding initial notification: \(error)")
                            } else {
                                print("Initial notification added successfully")
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.userSession.isAuthenticated = true
                            self.navigationActive = true // Triggers navigation to UserProfileTwoView
                            self.showingProfile = false // Dismisses the signup sheet
                        }
                    }
                }
            }
        }
    }
}

struct PasswordCriteriaView: View {
    let password: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Your password must contain at least")
                .font(.caption)
                .foregroundColor(.gray)
            RequirementText(isSatisfied: password.count >= 8, text: "8 characters")
            RequirementText(isSatisfied: password.rangeOfCharacter(from: .uppercaseLetters) != nil, text: "1 uppercase letter")
            RequirementText(isSatisfied: password.rangeOfCharacter(from: .lowercaseLetters) != nil, text: "1 lowercase letter")
            RequirementText(isSatisfied: password.rangeOfCharacter(from: .decimalDigits) != nil, text: "1 number")
            RequirementText(isSatisfied: password.range(of: ".*[^A-Za-z0-9].*", options: .regularExpression) != nil, text: "1 special character")
        }
    }
    
    private func RequirementText(isSatisfied: Bool, text: String) -> some View {
        HStack {
            Image(systemName: isSatisfied ? "checkmark.circle" : "xmark.circle")
                .foregroundColor(isSatisfied ? .green : .red)
            Text(text)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    // Create a State variable for the preview to simulate the binding
    @State static var previewShowingProfile = false

    static var previews: some View {
        // Pass the binding to the preview
        SignUpView(email: "test@example.com", showingProfile: $previewShowingProfile)
            .environmentObject(UserSession())  // Ensure to add this if your view relies on UserSession
    }
}
