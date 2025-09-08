//
//  DeepLinkNavigationViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct DeepLinkNavigationViewModifier: ViewModifier {
    @Binding var path: NavigationPath
    
    let chapters: [Chapter]
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                if let chapterNumber = Int(url.lastPathComponent) {
                    if let chapter = chapters.first(where: { $0.number == chapterNumber }) {
                        path.append(ChapterRoute(chapter: chapter, comicType: chapter.universe == nil ? .story : .specials))
                    }
                }
            }
    }
}

extension View {
    /// Adds deep link navigation to a view, allowing navigation to specific chapters based on URLs.
    /// - Parameters:
    ///   - path: A binding to the `NavigationPath` for managing the navigation stack.
    ///   - chapters: An array of chapters to use for resolving deep link URLs.
    func withDeepLinkNavigation(path: Binding<NavigationPath>, chapters: [Chapter]) -> some View {
        modifier(DeepLinkNavigationViewModifier(path: path, chapters: chapters))
    }
}
