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
        
        // This assumes your PaymentGateway can now return the full required details
        PaymentGateway.shared.createPaymentIntent(amount: totalAmount) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let details):
                    
                    var configuration = PaymentSheet.Configuration()
                    configuration.merchantDisplayName = "CLEAR OUT"
                    configuration.customer = .init(id: details.customerId, ephemeralKeySecret: details.ephemeralKeySecret)
                    
                    // Instantiates a PaymentSheet with the necessary details
                    self?.paymentSheet = PaymentSheet(paymentIntentClientSecret: details.clientSecret, configuration: configuration)
                    self?.showPaymentSheet = true
                    
                case .failure(let error):
                    print("Failed to create payment intent: \(error.localizedDescription)")
                }
            }
        }
    }
}
