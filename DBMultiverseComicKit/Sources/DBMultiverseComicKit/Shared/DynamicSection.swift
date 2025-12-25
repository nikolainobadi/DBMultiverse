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
                .withFont(.caption, autoSizeLineLimit: 1)
        }
    }
}

public extension View {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
