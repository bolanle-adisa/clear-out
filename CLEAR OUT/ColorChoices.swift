//
//  ColorChoices.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI

struct ColorChoice: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

let colorChoices: [ColorChoice] = [
    ColorChoice(name: "Red", color: .red),
        ColorChoice(name: "Green", color: .green),
        ColorChoice(name: "Blue", color: .blue),
        ColorChoice(name: "Orange", color: .orange),
        ColorChoice(name: "Yellow", color: .yellow),
        ColorChoice(name: "Pink", color: .pink),
        ColorChoice(name: "Purple", color: .purple),
        ColorChoice(name: "Teal", color: .teal),
        ColorChoice(name: "Indigo", color: .indigo),
        ColorChoice(name: "Gray", color: .gray),
        ColorChoice(name: "Brown", color: .brown),
        ColorChoice(name: "Mint", color: .mint),
        ColorChoice(name: "Cyan", color: .cyan),
        ColorChoice(name: "Lime", color: .green.opacity(0.5)),
        ColorChoice(name: "Maroon", color: Color(red: 0.5, green: 0, blue: 0)),
        ColorChoice(name: "Olive", color: Color(red: 0.5, green: 0.5, blue: 0)),
        ColorChoice(name: "Coral", color: Color(red: 1.0, green: 0.5, blue: 0.31)),
        ColorChoice(name: "Navy", color: Color(red: 0, green: 0, blue: 0.5)),
        ColorChoice(name: "Aqua", color: Color(red: 0, green: 1.0, blue: 1.0)),
        ColorChoice(name: "Cream", color: Color(red: 1.0, green: 0.99, blue: 0.82)),
        ColorChoice(name: "Dark Green", color: Color(red: 0, green: 0.39, blue: 0)),
        ColorChoice(name: "Violet", color: Color(red: 0.93, green: 0.51, blue: 0.93)),
        ColorChoice(name: "Sky Blue", color: Color(red: 0.53, green: 0.81, blue: 0.92)),
        ColorChoice(name: "Gold", color: Color(red: 1.0, green: 0.84, blue: 0)),
        ColorChoice(name: "Beige", color: Color(red: 0.96, green: 0.96, blue: 0.86))
]
