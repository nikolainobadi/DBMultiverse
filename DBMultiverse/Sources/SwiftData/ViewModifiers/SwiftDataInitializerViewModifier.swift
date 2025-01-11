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
    func initializeSwiftDataModelConatainer() -> some View {
        modifier(SwiftDataInitializerViewModifier())
    }
}