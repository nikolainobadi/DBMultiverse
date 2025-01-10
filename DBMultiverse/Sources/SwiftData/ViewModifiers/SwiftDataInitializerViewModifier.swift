//
//  SwiftDataInitializerViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import SwiftData

struct SwiftDataInitializerViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modelContainer(for: SwiftDataChapter.self)
    }
}

extension View {
    func initializeSwiftDataModelConatainer() -> some View {
        modifier(SwiftDataInitializerViewModifier())
    }
}
