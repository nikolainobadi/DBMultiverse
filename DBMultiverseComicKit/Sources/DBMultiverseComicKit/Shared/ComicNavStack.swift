//
//  ComicNavStack.swift
//
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

public struct ComicNavStack<Content: View>: View {
    let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("DB")
                            .textLinearGradient(.yellowText)
            
                        Text("Multiverse")
                            .textLinearGradient(.redText)
                    }
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .withFont(.title3, autoSizeLineLimit: 1)
                    
                    Divider()
                }
                .padding()
                
                content()
            }
        }
    }
}
