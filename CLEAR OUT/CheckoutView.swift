//
//  CheckoutView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/19/24.
//
import SwiftUI
import Stripe
import StripePaymentSheet
struct CheckoutView: View {
    @EnvironmentObject var cartManager: CartManager
    @StateObject var backendModel: MyBackendModel
    // State variables to store user input
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zipCode: String = ""
    @State private var country: String = ""
    @State private var showPaymentPresenter = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Shipping Information").font(.title2).bold()
                    CustomTextField(placeholder: "Name", text: $name)
                    CustomTextField(placeholder: "Address", text: $address)
                    CustomTextField(placeholder: "City", text: $city)
                    CustomTextField(placeholder: "State/Province", text: $state)
                    CustomTextField(placeholder: "ZIP/Postal Code", text: $zipCode)
                    CustomTextField(placeholder: "Country", text: $country)
                }
                Button("Proceed to Payment") {
                    if validateShippingInformation() {
                        let subtotal = cartManager.cartItems.reduce(0) { $0 + $1.price }
                        backendModel.preparePaymentSheet(subtotal: subtotal) // Make sure this method updates the `paymentSheet` property and sets a flag to show the sheet
                        showPaymentPresenter = true
                    } else {
                        // Handle validation failure
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .navigationTitle("Checkout")
        .sheet(isPresented: $showPaymentPresenter) {
            if let paymentSheet = backendModel.paymentSheet {
                PaymentSheetPresenter(paymentSheet: paymentSheet) {
                    // This closure is called after the payment sheet is dismissed
                    showPaymentPresenter = false
                    backendModel.showPaymentSheet = false // Reset the state if necessary
                }
            }
        }
    }
    
    func validateShippingInformation() -> Bool {
        // Implement actual validation logic here
        return !(name.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty || country.isEmpty)
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
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
            .background(Color(.systemBackground))
            .foregroundColor(.black)
    }
}
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(backendModel: MyBackendModel()).environmentObject(CartManager.shared)
    }
}
