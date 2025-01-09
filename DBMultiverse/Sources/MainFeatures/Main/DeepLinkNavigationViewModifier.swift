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
    func withDeepLinkNavigation(path: Binding<NavigationPath>, chapters: [Chapter]) -> some View {
        modifier(DeepLinkNavigationViewModifier(path: path, chapters: chapters))
    }
}