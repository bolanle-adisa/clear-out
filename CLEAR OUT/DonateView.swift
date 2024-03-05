//
//  DonateView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import MapKit

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @State private var selectedCenter: DonationCenter?

    var body: some View {
        NavigationView {
            VStack {
                Text("Nearby Donation Centers")
                    .font(.headline)
                    .padding()

                List(viewModel.donationCenters) { center in
                    VStack(alignment: .leading) {
                        Text(center.name).font(.headline)
                        Text("Address: \(center.address)")
                        Text("Hours: \(center.operationalHours)")
                        Text("Accepts: \(center.acceptedDonationTypes)")
                        
                        // Buttons for directions and more info
                        HStack {
                            // Get Directions Button
                            Button(action: {
                                // Open directions in Maps
                                let destination = MKMapItem(placemark: MKPlacemark(coordinate: center.coordinate))
                                destination.name = center.name
                                destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                            }) {
                                Text("Get Directions")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)

                            Spacer()

                            // Get More Info Button
                            Button(action: {
                                // Open Google search for more info
                                if let url = URL(string: "https://www.google.com/search?q=\(center.name.replacingOccurrences(of: " ", with: "+"))") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Get More Info")
                                    .foregroundColor(.blue)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                    .onTapGesture {
                        self.selectedCenter = center
                    }
                }
                Spacer()
            }
            .onAppear {
                viewModel.fetchDonationCenters()
            }
        }
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
