//
//  PreviewModifiersViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

struct PreviewModifiersViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .withNnErrorHandling()
            .environment(\.isPreview, true)
            .modelContainer(PreviewSampleData.container)
    }
}

extension View {
    /// Applies a set of modifiers to configure a view for use in previews.
    ///
    /// This method uses `PreviewModifiersViewModifier` to add common modifiers for previewing
    /// SwiftUI views, such as a loading view, error handling, and preview-specific environment settings.
    /// It also injects a model container with in-memory storage for preview data.
    ///
    /// - Returns: A modified view configured with preview-specific settings.
    func withPreviewModifiers() -> some View {
        modifier(PreviewModifiersViewModifier())
    }
}

/// Provides sample data and a model container for use in SwiftUI previews.
actor PreviewSampleData {
    /// A `ModelContainer` configured with in-memory storage and populated with sample data.
    /// This container is used to supply data for previews without affecting persistent storage.
    @MainActor
    static var container: ModelContainer = {
        // Create an in-memory model container for the `SwiftDataChapter` type.
        let container = try! ModelContainer(
            for: SwiftDataChapter.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        
        // Populate the container's main context with sample data.
        SwiftDataChapter.sampleList.forEach { container.mainContext.insert($0) }
        
        return container
    }()
    
    /// A sample chapter from the preloaded `sampleList` for use in previews.
    @MainActor
    static var sampleChapter: SwiftDataChapter {
        // Ensure the container is initialized.
        let _ = PreviewSampleData.container
        
        // Return the first sample chapter.
        return SwiftDataChapter.sampleList[0]
    }
}

extension SwiftDataChapter {
    static var sampleList: [SwiftDataChapter] {
        return [
            .init(name: "A really strange tournament!", number: 1, startPage: 0, endPage: 23, universe: nil, lastReadPage: 17, coverImageURL: ""),
            .init(name: "Lots of old foes here!", number: 2, startPage: 24, endPage: 47, universe: nil, lastReadPage: nil, coverImageURL: ""),
            .init(name: "Universe 3: visions of the future", number: 20, startPage: 425, endPage: 449, universe: 3, lastReadPage: nil, coverImageURL: ""),
            .init(name: "Deus Ex Machina", number: 25, startPage: 547, endPage: 555, universe: 1, lastReadPage: 549, coverImageURL: "")
        ]
    }
}
