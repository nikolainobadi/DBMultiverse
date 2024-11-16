//
//  MainFeaturesView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import SwiftUI

struct ChapterListFeatureView: View {
    @State private var selectedChapter: Chapter?
    @State private var sharedDataENV: SharedDataENV = .init()
    @AppStorage("lastReadPage") private var lastReadPage: Int = 0
    
    var body: some View {
        NavigationStack {
            ChapterListView(viewModel: .init(), lastReadPage: lastReadPage) { chapter in
                print("set selected chapter:", chapter.name)
                selectedChapter = chapter
            }
            .environmentObject(sharedDataENV)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Dragonball Multiverse")
            .navigationDestination(item: $selectedChapter) { chapter in
                ComicView(
                    lastReadPage: $lastReadPage,
                    viewModel: .customInit(chapter: chapter, lastReadPage: lastReadPage, env: sharedDataENV)
                )
            }
        }
    }
}


// MARK: - Extension Dependencies
extension ComicViewModel {
    static func customInit(chapter: Chapter, lastReadPage: Int, env: SharedDataENV) -> ComicViewModel {
        return .init(
            chapter: chapter,
            currentPageNumber: chapter.getCurrentPageNumber(lastReadPage: lastReadPage),
            delegate: env,
            onChapterFinished: env.finishChapter(number:)
        )
    }
}

extension Chapter {
    func getCurrentPageNumber(lastReadPage: Int) -> Int {
        return containsLastReadPage(lastReadPage) ? lastReadPage : startPage
    }
}
