//
//  PaymentSheetPresenter.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/24/24.
//

import Foundation
import SwiftUI
import Stripe
import StripePaymentSheet

struct PaymentSheetPresenter: UIViewControllerRepresentable {
    var paymentSheet: PaymentSheet
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Placeholder
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Ensuring the PaymentSheet is only presented once, preventing infinite loop
        if uiViewController.presentedViewController == nil {
            paymentSheet.present(from: uiViewController) { result in
                // Handle the payment result here
                self.onDismiss()
            }
        }
    }
}
