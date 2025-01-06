//
//  LinearGradient+Extensions.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/6/25.
//

import SwiftUI

extension LinearGradient {
    static var yellowText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.yellow, .yellow, Color.yellow.opacity(0.7)])
    }
    
    static var redText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.red, .red.opacity(0.9), .red.opacity(0.7)])
    }
}


// MARK: - Helpers
fileprivate extension LinearGradient {
    static func makeTopBottomTextGradient(colors: [Color]) -> LinearGradient {
        return .init(gradient: .init(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}
