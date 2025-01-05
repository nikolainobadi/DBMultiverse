//
//  CustomButtonStyle.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import SwiftUI

public struct CustomButtonStyle: ButtonStyle {
    let textColor: Color
    
    public func makeBody(configuration: Configuration) -> some View {
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

public extension ButtonStyle where Self == CustomButtonStyle {
    static func customButtonStyle(textColor: Color) -> CustomButtonStyle {
        return .init(textColor: textColor)
    }
}
