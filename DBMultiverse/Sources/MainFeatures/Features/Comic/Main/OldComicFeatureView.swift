//
//  ComicFeatureView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/2/24.
//

import SwiftUI

struct OldComicFeatureView: View {
    @State private var selectedChapter: Chapter?
    @State private var selection: ComicType = .story
    @EnvironmentObject var sharedDataENV: SharedDataENV
    @AppStorage(.lastReadPageKey) private var lastReadPage: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selection) {
                    ForEach(ComicType.allCases, id: \.self) { type in
                        Text(type.title)
                            .tag(type)
                    }
                }
                .padding()
                .pickerStyle(.segmented)
                
                switch selection {
                case .story:
                    ChapterListView(viewModel: .init(store: sharedDataENV), lastReadPage: lastReadPage) { chapter in
                        selectedChapter = chapter
                    }
                case .specials:
                    List {
                        if let currentChapter = sharedDataENV.specials.flatMap({ $0.chapters }).first(where: { $0.containsLastReadPage(lastReadPage) }) {
                            ChapterRow(chapter: currentChapter, isCurrentChapter: true)
                        }
                        
                        ForEach(sharedDataENV.specials) { special in
                            Section(special.title) {
                                ForEach(special.chapters) { chapter in
                                    ChapterRow(chapter: chapter, isCurrentChapter: false)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(selection.navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut, value: selection)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // TODO: -
//            .navigationDestination(item: $selectedChapter) { chapter in
//                ComicView(
//                    lastReadPage: $lastReadPage,
//                    viewModel: .customInit(chapter: chapter, lastReadPage: lastReadPage, env: sharedDataENV)
//                )
//            }
        }
    }
}


// MARK: - Preview
#Preview {
    OldComicFeatureView()
        .environmentObject(SharedDataENV())
}


// MARK: - Dependencies
enum ComicType: String, CaseIterable {
    case story, specials
    
    var title: String {
        return rawValue.capitalized
    }
    
    var navTitle: String {
        switch self {
        case .story:
            return "Main Story"
        case .specials:
            return "Univers Specials"
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
