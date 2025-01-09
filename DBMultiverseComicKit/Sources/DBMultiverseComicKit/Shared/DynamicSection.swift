//
//  DynamicSection.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

public struct DynamicSection<Content: View>: View {
    let title: String
    let gradient: LinearGradient?
    let content: () -> Content
    
    public init(_ title: String, gradient: LinearGradient? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.gradient = gradient
    }
    
    public var body: some View {
        Section {
            content()
        } header: {
            Text(title)
                .showingViewWithOptional(gradient) { gradient in
                    Text(title)
                        .textLinearGradient(gradient)
                }
                .withFont(isPad ? .body : .caption, autoSizeLineLimit: 1)
        }
    }
}

public extension View {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

enum TitleFormatter {
    static func formatTitle(_ title: String) -> (yellowText: String, redText: String)? {
        let components = title.split(separator: " ").map({ String($0) })
            
            guard components.count > 1 else {
                return nil
            }
            
            let midIndex = components.count / 2
            let isEven = components.count.isMultiple(of: 2)
            
            let yellowText = components[0..<(isEven ? midIndex : midIndex + 1)].joined(separator: " ")
            let redText = components[(isEven ? midIndex : midIndex + 1)...].joined(separator: " ")
            
            return (yellowText, redText)
    }
}
