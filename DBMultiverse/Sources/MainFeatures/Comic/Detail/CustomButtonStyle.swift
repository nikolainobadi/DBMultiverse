//
//  CustomButtonStyle.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import SwiftUI

/// Custom button style with adjustable text color.
struct CustomButtonStyle: ButtonStyle {
    /// The color of the button text.
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .padding()
            .frame(maxHeight: .infinity)
            .background(.gray.opacity(0.5))
            .foregroundStyle(textColor)
            .clipShape(.rect(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

extension ButtonStyle where Self == CustomButtonStyle {
    /// Creates a custom button style with a specified text color.
    /// - Parameter textColor: The color of the button text.
    static func customButtonStyle(textColor: Color) -> CustomButtonStyle {
        return .init(textColor: textColor)
    }
}
