//
//  PaymentMethodsView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/26/24.
//

import SwiftUI

// PaymentMethod model declared within the same file for simplicity
struct PaymentMethod: Identifiable {
    let id: String
    let cardBrand: String
    let last4: String
}

// BankCardView represents the visual layout of a bank card
struct BankCardView: View {
    var paymentMethod: PaymentMethod

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 200)
                .shadow(radius: 10)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(paymentMethod.cardBrand)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }

                Spacer()

                Text("**** **** **** \(paymentMethod.last4)")
                    .font(.title2)
                    .foregroundColor(.white)

                HStack {
                    VStack(alignment: .leading) {
                        Text("CARD HOLDER")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("Bolanle Adisa") // Replace with actual user name if available
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("EXPIRES")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("08/24") // Replace with actual expiry date if available
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }
}

// PaymentMethodsView which displays a list of bank cards
struct PaymentMethodsView: View {
    let paymentMethods: [PaymentMethod]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(paymentMethods) { paymentMethod in
                    BankCardView(paymentMethod: paymentMethod)
                }
            }
            .padding()
        }
        .navigationTitle("Payment Information")
    }
}

// PaymentMethodsView_Previews providing hardcoded payment methods for the preview
struct PaymentMethodsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodsView(paymentMethods: [
            PaymentMethod(id: "1", cardBrand: "Visa", last4: "4242"),
            PaymentMethod(id: "2", cardBrand: "MasterCard", last4: "5678"),
            PaymentMethod(id: "3", cardBrand: "Amex", last4: "9012")
        ])
    }
}
