//
// SettingsView.swift
// CLEAR OUT
//
// Created by Bolanle Adisa on 3/27/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontScale") private var fontScale: Double = 1.0
    @AppStorage("isVoiceOverEnabled") private var isVoiceOverEnabled = false
    @AppStorage("isSpeechRecognitionEnabled") private var isSpeechRecognitionEnabled = false
    @AppStorage("isKeyboardNavigationEnabled") private var isKeyboardNavigationEnabled = false
    @AppStorage("selectedColorTheme") private var selectedColorTheme = 0
    @AppStorage("isAudioDescriptionEnabled") private var isAudioDescriptionEnabled = false
    
    let colorThemes = ["Default", "High Contrast", "Grayscale"]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(UIColor.label))
                    .padding()
                
                Form {
                    Section(header: Text("Appearance")) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .accessibility(label: Text("Enable Dark Mode"))
                            .accessibility(hint: Text("Toggles between light and dark app appearance"))
                    }
                    
                    Section(header: Text("Text Scaling")) {
                        HStack {
                            Text("Font Scale")
                            Slider(value: $fontScale, in: 1.0...2.0, step: 0.1)
                                .accessibility(label: Text("Adjust Font Scale"))
                                .accessibility(value: Text("\(fontScale, specifier: "%.1f")"))
                        }
                    }
                    
                    Section(header: Text("Screen Reading")) {
                        Toggle("VoiceOver", isOn: $isVoiceOverEnabled)
                            .accessibility(label: Text("Enable VoiceOver"))
                            .accessibility(hint: Text("Provides audio feedback for app navigation and content"))
                    }
                    
                    Section(header: Text("Speech Recognition")) {
                        Toggle("Speech Recognition", isOn: $isSpeechRecognitionEnabled)
                            .accessibility(label: Text("Enable Speech Recognition"))
                            .accessibility(hint: Text("Allows controlling the app using voice commands"))
                    }
                    
                    Section(header: Text("Keyboard Navigation")) {
                        Toggle("Keyboard Navigation", isOn: $isKeyboardNavigationEnabled)
                            .accessibility(label: Text("Enable Keyboard Navigation"))
                            .accessibility(hint: Text("Allows navigating the app using keyboard shortcuts"))
                    }
                    
                    Section(header: Text("Color Themes")) {
                        Picker("Color Theme", selection: $selectedColorTheme) {
                            ForEach(0..<colorThemes.count) { index in
                                Text(colorThemes[index]).tag(index)
                            }
                        }
                        .accessibility(label: Text("Select Color Theme"))
                        .accessibility(value: Text(colorThemes[selectedColorTheme]))
                    }
                    
                    Section(header: Text("Audio Descriptions")) {
                        Toggle("Audio Descriptions", isOn: $isAudioDescriptionEnabled)
                            .accessibility(label: Text("Enable Audio Descriptions"))
                            .accessibility(hint: Text("Provides audio descriptions for visual content"))
                    }
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .modifier(ScaledFont(size: 18 * fontScale))
            .environment(\.colorScheme, isDarkMode ? .dark : .light)
            .accentColor(colorTheme.accentColor)
            .background(colorTheme.backgroundColor)
        }
    }
    
    var colorTheme: ColorTheme {
        ColorTheme(rawValue: selectedColorTheme) ?? .default
    }
}

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var size: Double
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.system(size: scaledSize))
    }
}

enum ColorTheme: Int {
    case `default`
    case highContrast
    case grayscale
    
    var accentColor: Color {
        switch self {
        case .default:
            return .blue
        case .highContrast:
            return .black
        case .grayscale:
            return .gray
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .default:
            return .clear
        case .highContrast:
            return .white
        case .grayscale:
            return .white
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
