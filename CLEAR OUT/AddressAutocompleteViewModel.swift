//
//  AddressAutocompleteViewModel.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/24/24.
//
import Foundation
import Combine

class AddressAutocompleteViewModel: ObservableObject {
    @Published var addressLine1: String = ""
    @Published var autocompleteSuggestions: [String] = []
    
    private var cancellables: Set<AnyCancellable> = []

    init() {
        $addressLine1
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { address in
                print("FlatMap for address: \(address)")
                return self.fetchAutocompleteSuggestions(address)
            }
            .sink { [weak self] in
                print("Autocomplete suggestions updated: \($0)")
                self?.autocompleteSuggestions = $0
            }
            .store(in: &cancellables)
    }

    private func fetchAutocompleteSuggestions(_ input: String) -> AnyPublisher<[String], Never> {
        guard !input.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return Future<[String], Never> { promise in
            AddressValidationService.shared.fetchAutocompleteSuggestions(input: input) { suggestions in
                promise(.success(suggestions))
            }
        }
        .eraseToAnyPublisher()
    }
}
