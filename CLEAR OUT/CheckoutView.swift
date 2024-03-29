//
//  CheckoutView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/19/24.
//
import SwiftUI
import Stripe
import StripePaymentSheet
import FirebaseAuth
import FirebaseFirestore

struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @StateObject var backendModel: MyBackendModel
    @State private var name: String = ""
    @State private var addressLine1: String = ""
    @State private var addressLine2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    @State private var phoneNumber: String = ""
    @State private var showPaymentPresenter = false
    @State private var autocompleteSuggestions: [String] = []
    @State private var selectedPlaceId: String?
    @State private var paymentResult: PaymentSheetResult?
    @State private var showPaymentConfirmation = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Shipping Information")
                    .font(.title2)
                    .bold()

                CustomTextField(placeholder: "Full Name", text: $name)
                    .keyboardType(.default)

                CustomPhoneNumberField(text: $phoneNumber)
                
                CustomAutocompleteTextField(
                    placeholder: "Address Line 1",
                    text: $addressLine1,
                    suggestions: $autocompleteSuggestions,
                    selectedPlaceId: $selectedPlaceId,
                    onCommit: {
                        if let placeId = selectedPlaceId {
                                AddressValidationService.shared.getPlaceDetails(placeId: placeId) { placeDetails in
                                    if let details = placeDetails {
                                        addressLine1 = details.streetAddress
                                        addressLine2 = details.subpremise
                                        city = details.city
                                        state = details.state
                                        zipCode = details.zipCode
                                        country = details.country
                                    
                                    // Validate the address
                                    AddressValidationService.shared.validateAddress(placeId: placeId) { isValid in
                                        if isValid {
                                            // Address is valid, proceed
                                            print("Address is valid")
                                        } else {
                                            // Address is invalid, show an error message
                                            print("Address is invalid")
                                            // You can show an alert or display an error message here
                                        }
                                    }
                                }
                            }
                        }
                    }
                )
                .onChange(of: addressLine1) { newValue in
                    AddressValidationService.shared.fetchAutocompleteSuggestions(input: newValue) { suggestions in
                        autocompleteSuggestions = suggestions
                    }
                }

                CustomTextField(placeholder: "Address Line 2 (Optional)", text: $addressLine2)
                    .keyboardType(.default)
            }

            Button("Proceed to Payment") {
                if validateShippingInformation() {
                    let subtotal = cartManager.cartItems.reduce(0) { $0 + $1.price }
                    backendModel.preparePaymentSheet(subtotal: subtotal)
                    showPaymentPresenter = true
                } else {
                    // Handle validation failure
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 20)
        }
        .padding()
        .navigationTitle("Checkout")
        .sheet(isPresented: $showPaymentPresenter) {
            if let paymentSheet = backendModel.paymentSheet {
                PaymentSheetPresenter(paymentSheet: paymentSheet) { result in
                    handlePaymentResult(result)
                    showPaymentPresenter = false
                    backendModel.showPaymentSheet = false
                }
            }
        }
        .sheet(isPresented: $showPaymentConfirmation) {
            // Pass a closure to handle what happens when "Continue Shopping" is tapped
            PaymentConfirmationView {
                presentationMode.wrappedValue.dismiss() // Dismiss the checkout view
            }
            .environmentObject(cartManager)
        }
    }

    func validateShippingInformation() -> Bool {
        !(name.isEmpty || phoneNumber.isEmpty || addressLine1.isEmpty)
    }
    
    func parentMethodToHandleSelection(placeId: String?) {
        guard let placeId = placeId else { return }
        AddressValidationService.shared.getPlaceDetails(placeId: placeId) { placeDetails in
            if let details = placeDetails {
                DispatchQueue.main.async {
                    self.addressLine1 = "\(details.streetAddress ?? ""), \(details.subpremise ?? "")"
                    self.city = details.city ?? ""
                    self.state = details.state ?? ""
                    self.zipCode = details.zipCode ?? ""
                    self.country = details.country ?? ""
                }
            }
        }
    }
    
    func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            print("Payment completed")
            showPaymentConfirmation = true
            createPaymentSuccessNotification()
            saveAddressToFirestore()
            savePurchasedItemsToFirestore() // Save purchased items to Firestore
        case .canceled:
            print("Payment canceled")
        case .failed(let error):
            print("Payment failed: \(error.localizedDescription)")
        }
    }
    
    func savePurchasedItemsToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found. Unable to save purchased items.")
            return
        }

        let db = Firestore.firestore()
        let purchasedItemsData = cartManager.cartItems.map { cartItem in
            [
                "name": cartItem.item.name,
                "description": cartItem.item.description,
                "price": cartItem.price,
                "size": cartItem.item.size,
                "color": cartItem.item.color,
                "mediaUrl": cartItem.item.mediaUrl,
                "isVideo": cartItem.item.isVideo,
                "rentPrice": cartItem.item.rentPrice,
                "rentPeriod": cartItem.item.rentPeriod,
                "userId": cartItem.item.userId,
                "timestamp": FieldValue.serverTimestamp(),
                "sold": false
            ]
        }

        for itemData in purchasedItemsData {
            db.collection("users").document(userId).collection("purchasedItems").addDocument(data: itemData) { error in
                if let error = error {
                    print("Error saving purchased item: \(error.localizedDescription)")
                } else {
                    print("Purchased item saved successfully")
                }
            }
        }
    }
    
    func saveAddressToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found. Unable to save address.")
            return
        }
        let db = Firestore.firestore()
        
        let addressData = [
            "name": name,
            "phoneNumber": phoneNumber,
            "addressLine1": addressLine1,
            "addressLine2": addressLine2,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "country": country
        ]
        
        db.collection("users").document(userId).collection("addresses").addDocument(data: addressData) { error in
            if let error = error {
                print("Error saving address: \(error.localizedDescription)")
            } else {
                print("Address saved successfully")
            }
        }
    }
    
    func createPaymentSuccessNotification() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let notification = UserNotification(id: UUID().uuidString, title: "Payment Successful", message: "Your payment was successful. Thank you for your purchase!", timestamp: Date(), read: false)
        let notificationData = ["id": notification.id, "title": notification.title, "message": notification.message, "timestamp": Timestamp(date: notification.timestamp), "read": notification.read] as [String : Any]
        
        db.collection("users").document(userId).collection("notifications").document(notification.id).setData(notificationData) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully")
            }
        }
    }
}

// Reusable button style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// Reusable custom text field
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default // Default keyboard type

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10)) // Increased padding
            .keyboardType(keyboardType)
            .overlay(
                RoundedRectangle(cornerRadius: 8) // More rounded corners
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2) // Thicker and lighter border
            )
            .background(Color.white) // Consider changing if you have a different theme
            .foregroundColor(.black)
    }
}

struct CustomPhoneNumberField: View {
    @Binding var text: String

    var body: some View {
        TextField("Phone Number", text: $text)
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
            .keyboardType(.phonePad)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .background(Color.white)
            .foregroundColor(.black)
            .onChange(of: text) { newValue in
                text = formatPhoneNumber(newValue)
            }
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        let cleanedInput = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXX-XXX-XXXX"
        var result = ""
        var index = cleanedInput.startIndex
        for ch in mask where index < cleanedInput.endIndex {
            if ch == "X" {
                result.append(cleanedInput[index])
                index = cleanedInput.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

struct CustomAutocompleteTextField: View {
    var placeholder: String
    @Binding var text: String
    @Binding var suggestions: [String]
    @Binding var selectedPlaceId: String?
    var onCommit: () -> Void = {}
    var onSuggestionTapped: ((String) -> Void)?
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $text, onCommit: onCommit)
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                .background(Color(.systemBackground))
                .foregroundColor(.black)
                .autocapitalization(.none)
            
            ZStack {
                if !suggestions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                Text(suggestion)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        self.text = suggestion
                                        self.selectedPlaceId = extractPlaceId(from: suggestion)
                                        self.suggestions = [] // Clears the autocomplete suggestions
                                        if let placeId = self.selectedPlaceId {
                                            self.onSuggestionTapped?(placeId) // Call the closure with the placeId
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .frame(height: suggestions.isEmpty ? 0 : 150) // Hide if empty
                }
            }
        }
    }
    
    private func extractPlaceId(from suggestion: String) -> String? {
        let components = suggestion.components(separatedBy: ",")
        if let lastComponent = components.last {
            return lastComponent.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(backendModel: MyBackendModel()).environmentObject(CartManager.shared)
    }
}
