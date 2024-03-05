//
//  ItemRow.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI

struct ItemRow: View {
    let item: ItemForSaleAndRent

    var body: some View {
        HStack(spacing: 15) {
            MediaView(item: item)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name).font(.headline)
                Group {
                    if let salePrice = item.price, salePrice > 0 {
                        Text("Sale: $\(salePrice, specifier: "%.2f")").font(.subheadline)
                    }
                    if let rentPrice = item.rentPrice, rentPrice > 0, let rentPeriod = item.rentPeriod, rentPeriod != "Not Applicable" {
                        Text("Rent: $\(rentPrice, specifier: "%.2f") / \(rentPeriod)").font(.subheadline)
                    }
                }
            }

            Spacer() // This pushes everything to the left and allows the row to expand fully
        }
        .frame(maxWidth: .infinity) // Ensure the HStack fills the available width
    }
}
