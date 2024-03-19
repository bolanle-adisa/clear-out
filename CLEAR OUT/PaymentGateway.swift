//
//  PaymentGateway.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/18/24.
//

import Foundation

class PaymentGateway {
    static let shared = PaymentGateway()

    private let endpointURL = URL(string: "https://us-central1-clearout-82860.cloudfunctions.net/api/create-payment-intent")!

    func createPaymentIntent(amount: Int, completion: @escaping (Result<(clientSecret: String, ephemeralKeySecret: String, customerId: String), Error>) -> Void) {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["amount": amount]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                return
            }
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let clientSecret = jsonObject["paymentIntent"] as? String,
                   let ephemeralKeySecret = jsonObject["ephemeralKey"] as? String,
                   let customerId = jsonObject["customer"] as? String {
                    DispatchQueue.main.async {
                        completion(.success((clientSecret, ephemeralKeySecret, customerId)))
                    }
                } else {
                    DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        task.resume()
    }
}
