//
//  MyBackendModel.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/19/24.
//
import SwiftUI
import Stripe
import StripePaymentSheet
class MyBackendModel: ObservableObject {
    @Published var paymentSheet: PaymentSheet?
    @Published var showPaymentSheet = false
    
    func preparePaymentSheet(subtotal: Double) {
        let totalAmount = Int(subtotal * 100) // Convert to cents for Stripe
        
        PaymentGateway.shared.createPaymentIntent(amount: totalAmount) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let details):
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "CLEAR OUT"
                    
                    // Configure for Apple Pay
                    configuration.applePay = .init(
                        merchantId: "your.merchant.id.here",
                        merchantCountryCode: "US" // Use your merchant country code
                    )
                    
                    configuration.customer = .init(id: details.customerId, ephemeralKeySecret: details.ephemeralKeySecret)
                    
                    self?.paymentSheet = PaymentSheet(paymentIntentClientSecret: details.clientSecret, configuration: configuration)
                    self?.showPaymentSheet = true
                case .failure(let error):
                    print("Failed to create payment intent: \(error.localizedDescription)")
                    self?.showPaymentSheet = false
                }
            }
        }
    }
}
