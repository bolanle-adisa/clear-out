//
//  AddressValidationService.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/24/24.
//
import Foundation

class AddressValidationService {
    static let shared = AddressValidationService()

    func fetchAutocompleteSuggestions(input: String, completion: @escaping ([String]) -> Void) {
        let endpoint = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&key=\(APIKeys.googlePlaces)"
        print("Fetching autocomplete suggestions for input: \(input)")

        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error occurred: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data in response.")
                return
            }
            do {
                let decoder = JSONDecoder()
                let autocompleteResponse = try decoder.decode(AutocompleteResponse.self, from: data)
                let suggestions = autocompleteResponse.predictions.map { $0.description }
                print("Received suggestions: \(suggestions)")
                DispatchQueue.main.async {
                    completion(suggestions)
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }


    func validateAddress(placeId: String, completion: @escaping (Bool) -> Void) {
        let endpoint = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&key=\(APIKeys.googlePlaces)"
        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            do {
                let decoder = JSONDecoder()
                let placeDetailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(placeDetailsResponse.result != nil)
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func getPlaceDetails(placeId: String, completion: @escaping (PlaceDetails?) -> Void) {
        let endpoint = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&key=\(APIKeys.googlePlaces)"
        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            do {
                let decoder = JSONDecoder()
                let placeDetailsResponse = try decoder.decode(PlaceDetailsResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(placeDetailsResponse.result)
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct AutocompleteResponse: Decodable {
    let predictions: [Prediction]
}

struct Prediction: Decodable {
    let description: String
}
