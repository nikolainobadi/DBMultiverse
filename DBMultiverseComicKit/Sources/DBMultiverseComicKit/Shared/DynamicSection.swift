//
//  DynamicSection.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

struct DynamicSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        Section {
            content()
        } header: {
            Text(title)
                .withFont(isPad ? .body : .caption, autoSizeLineLimit: 1)
        }
    }
}

extension View {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
