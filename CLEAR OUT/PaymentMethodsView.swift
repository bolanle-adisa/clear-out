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

// BankAccount model for bank account information
struct BankAccount: Identifiable {
    let id: String
    let bankName: String
    let accountNumber: String
}

struct BankCardView: View {
    var paymentMethod: PaymentMethod

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 300, height: 200)
            .overlay(
                VStack(alignment: .leading) {
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
                        Text("Bolanle Adisa") // Replace with actual user name if available
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text("08/24") // Replace with actual expiry date if available
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            )
            .shadow(radius: 10)
    }
}

struct BankAccountView: View {
    var bankAccount: BankAccount

    var body: some View {
        HStack {
            bankLogo(bankName: bankAccount.bankName)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            VStack(alignment: .leading) {
                Text(bankAccount.bankName)
                    .font(.headline)
                Text("**** \(bankAccount.accountNumber)")
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    func bankLogo(bankName: String) -> some View {
            let imageName: String
            switch bankName {
            case "Chase Bank":
                imageName = "chase" // Replace with actual logo image name if available
            case "Bank of America":
                imageName = "boaLogo" // Replace with actual logo image name if available
            case "Wells Fargo":
                imageName = "wellsfargoLogo" // Replace with actual logo image name if available
            default:
                imageName = "banknote" // Generic placeholder
            }
            return Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }

struct PaymentMethodsView: View {
    let paymentMethods: [PaymentMethod]
    let bankAccounts: [BankAccount]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) { // Alignment set to .leading
                Text("My Cards")
                    .font(.headline)
                    .padding([.horizontal, .top])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(paymentMethods) { paymentMethod in
                            BankCardView(paymentMethod: paymentMethod)
                        }
                    }
                    .padding(.horizontal)
                }

                Text("Bank Accounts")
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(bankAccounts) { bankAccount in
                    BankAccountView(bankAccount: bankAccount)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("Payment Information") // Set title for the page
    }
}

// Preview providers
struct PaymentMethodsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodsView(
            paymentMethods: [
                PaymentMethod(id: "1", cardBrand: "Visa", last4: "4242"),
                PaymentMethod(id: "2", cardBrand: "MasterCard", last4: "5678"),
                PaymentMethod(id: "3", cardBrand: "Amex", last4: "9012")
            ],
            bankAccounts: [
                BankAccount(id: "1", bankName: "Chase Bank", accountNumber: "4791"),
//                BankAccount(id: "2", bankName: "Bank of America", accountNumber: "4883"),
//                BankAccount(id: "3", bankName: "Wells Fargo", accountNumber: "5690"),
            ]
        )
    }
}
