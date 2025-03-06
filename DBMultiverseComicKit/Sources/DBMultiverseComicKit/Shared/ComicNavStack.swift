//
//  ComicNavStack.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

public struct ComicNavStack<Content: View>: View {
    @Binding var path: NavigationPath
    
    let content: () -> Content
    
    public init(path: Binding<NavigationPath>, @ViewBuilder content: @escaping () -> Content) {
        self._path = path
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            VStack {
                ComicNavBar()
                
                content()
            }
        }
    }
}

public struct ComicNavBar: View {
    public init() { }
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Multiverse")
                    .textLinearGradient(.yellowText)
    
                Text("Reader")
                    .textLinearGradient(.redText)
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .withFont(.title3, autoSizeLineLimit: 1)
            
            Divider()
        }
        .padding()
    }
}
