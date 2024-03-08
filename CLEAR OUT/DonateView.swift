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
                        if let distance = center.distance {
                               Text(String(format: "%.1f km", distance / 1000)) // Convert meters to kilometers
                                   .padding(.top, 1)
                           }
                        Text("Address: \(center.address)")
//                        Text("Hours: \(center.operationalHours)")
//                        Text("Accepts: \(center.acceptedDonationTypes)")
                        .padding(.bottom)

                        HStack(spacing: 20) {
                            Button(action: {
                                openDirections(center: center)
                            }) {
                                buttonContent(title: "Directions")
                            }

                            Button(action: {
                                openMoreInfo(center: center)
                            }) {
                                buttonContent(title: "More Info")
                            }
                        }
                    }
                    .padding()
                    .buttonStyle(PlainButtonStyle()) // Prevents entire VStack from being clickable.
                }
                .listStyle(PlainListStyle()) // Removes list row selection style.
            }
        }
    }

    private func buttonContent(title: String) -> some View {
        Text(title)
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
    }

    private func openDirections(center: DonationCenter) {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: center.coordinate))
        destination.name = center.name
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func openMoreInfo(center: DonationCenter) {
        if let url = URL(string: "https://www.google.com/search?q=\(center.name.replacingOccurrences(of: " ", with: "+"))") {
            UIApplication.shared.open(url)
        }
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
