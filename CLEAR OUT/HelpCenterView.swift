//
// HelpCenterView.swift
// CLEAR OUT
//
// Created by Bolanle Adisa on 3/27/24.
//

import SwiftUI
import FirebaseCoreInternal

struct Constants {
    static let instagram = "https://www.instagram.com/clearoutcollege/"
    static let privacy = "https://docs.google.com/document/d/1dxVvJk4LGTDpVzPv-rk7OXUpRFM5H_vRXqa4DXIqcjY/edit?usp=sharing"
}

struct AboutUsView: View {
    var body: some View {
        VStack {
            Text("About Us")
                .font(.largeTitle)
                .padding()
            
            Text("We are ClearOut, a company dedicated to providing a platform for buying and selling pre-owned items.")
                .padding()
            
            // Add more content as needed
        }
        .navigationTitle("About Us")
    }
}

struct HelpCenterView: View {
    @State private var changeSize = 0.0
    @State var textFeildText: String = ""
    @State var dataArray: [String] = []
    @State private var showAboutUsView = false
    

    var body: some View {
        VStack {
            Form {
                Button(action: {
                    // Handle track returns action
                }) {
                    Text("Return Item")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Section {
                    
                } header: {
                    Text("RETURNS")
                        .font(.system(size: 16, weight: .semibold))
                } footer: {
                    Text("Once your return is received and inspected, we will notify you of the approval or rejection of your refund. \n\nIf approved, your refund will be processed, and a credit will automatically be applied to your original method of payment within 3 business days.\n\nPlease note that shipping costs are non-refundable, and the cost of return shipping may be deducted from your refund depending on the reason for return.")
                }
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 18))

                Section {
                    Button("About Us") {
                        showAboutUsView = true
                    }
                    .accessibilityLabel("about us")
                    .accessibilityAddTraits(.isButton)

                    Link(destination: URL(string: Constants.instagram)!, label: {
                        Label("Follow us on Instagram @ClearOut", systemImage: "link")
                    })
                    .accessibilityLabel("Follow us on Instagram @ClearOut")

                    Link(destination: URL(string: Constants.privacy)!, label: {
                        Label("Privacy policy", systemImage: "lock")
                    })
                    .accessibilityLabel("Privacy policy")
                }
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 18, weight: .semibold))

                VStack {
                    Button("Leave us a review") {
                        // Handle Leave us a review action
                    }

                    TextField("Type something here..", text: $textFeildText)
                        .padding()
                        .background(Color.gray.opacity(0.3).cornerRadius(10))
                        .foregroundColor(Color(UIColor.label))
                        .font(.headline)

                    Button(action: {
                        // Handle send action
                    }) {
                        Text("Send")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    ForEach(dataArray, id: \.self) { data in
                        Text(data)
                    }
                }
                .foregroundColor(Color(UIColor.label))
                .font(.system(size: 18, weight: .semibold))
            }
        }
        .navigationTitle("HOW CAN WE HELP?")
        .sheet(isPresented: $showAboutUsView) {
                    AboutUsView()
                }
    }

    func textIsAppropriate() -> Bool {
        return textFeildText.count >= 3
    }

    func saveText() {
        dataArray.append(textFeildText)
        textFeildText = ""
    }
}

struct HelpCenterView_Previews: PreviewProvider {
    static var previews: some View {
        HelpCenterView()
    }
}
