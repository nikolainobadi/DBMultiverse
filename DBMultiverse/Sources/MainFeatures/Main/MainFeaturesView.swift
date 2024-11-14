//
//  MainFeaturesView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import SwiftUI

struct ChapterListFeatureView: View {
    @State private var selectedChapter: Chapter?
    @AppStorage("lastReadPage") private var lastReadPage: Int = 0
    
    var body: some View {
        NavigationStack {
            ChapterListView(viewModel: .init(), lastReadPage: lastReadPage) { chapter in
                selectedChapter = chapter
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Dragonball Multiverse")
            .navigationDestination(item: $selectedChapter) { chapter in
                ComicView(lastReadPage: $lastReadPage, viewModel: .customInit(chapter: chapter, lastReadPage: lastReadPage))
            }
        }
    }
}


// MARK: - Extension Dependencies
extension ComicViewModel {
    static func customInit(chapter: Chapter, lastReadPage: Int) -> ComicViewModel {
        return .init(chapter: chapter, currentPageNumber: chapter.getCurrentPageNumber(lastReadPage: lastReadPage))
    }
}

extension Chapter {
    func getCurrentPageNumber(lastReadPage: Int) -> Int {
        return containsLastReadPage(lastReadPage) ? lastReadPage : startPage
    }
}
