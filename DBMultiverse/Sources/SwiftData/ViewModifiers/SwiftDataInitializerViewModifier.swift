//
//  SwiftDataInitializerViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import SwiftData

struct SwiftDataInitializerViewModifier: ViewModifier {
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    func body(content: Content) -> some View {
        content
            .modelContainer(for: SwiftDataChapter.self)
    }
}

extension View {
    /// Adds a SwiftData model container to the view, enabling persistence for the specified SwiftData model.
    func initializeSwiftDataModelContainer() -> some View {
        modifier(SwiftDataInitializerViewModifier())
    }
}
