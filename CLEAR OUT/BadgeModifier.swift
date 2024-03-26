//
//  BadgeModifier.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/26/24.
//

import Foundation
import SwiftUI

struct BadgeModifier: ViewModifier {
    var count: Int

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            if count > 0 {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 10, y: -10)
            }
        }
    }
}

extension View {
    func badge(count: Int) -> some View {
        self.modifier(BadgeModifier(count: count))
    }
}
