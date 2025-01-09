//
//  LinearGradient+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI

public extension LinearGradient {
    static var redText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.red, .red.opacity(0.9), .red.opacity(0.7)])
    }
    
    static var yellowText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.yellow, .yellow, Color.yellow.opacity(0.7)])
    }
    
    static var starrySky: LinearGradient {
        return makeTopBottomTextGradient(colors: [.init(red: 0.0, green: 0.0, blue: 0.5), .init(red: 0.0, green: 0.4, blue: 1.0)])
    }
}


// MARK: - Helpers
fileprivate extension LinearGradient {
    static func makeTopBottomTextGradient(colors: [Color]) -> LinearGradient {
        return .init(gradient: .init(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}
