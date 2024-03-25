//
//  PaymentConfirmationView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/25/24.
//
import Foundation
import SwiftUI

struct PaymentConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    var continueShopping: () -> Void // Closure to handle continue shopping action
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
                .padding(.top, 50)
            
            Text("Payment Successful")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Thank you for your purchase!")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 10)
            
            Spacer()
            
            Button(action: {
                cartManager.clearCart() // Clear the cart
                continueShopping() // Call the closure when button is tapped
                presentationMode.wrappedValue.dismiss() // Dismiss the payment confirmation view
            }) {
                Text("Continue Shopping")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct PaymentConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentConfirmationView(continueShopping: {})
            .environmentObject(CartManager.shared)
    }
}
