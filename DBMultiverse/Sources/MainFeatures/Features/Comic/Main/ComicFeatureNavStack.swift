//
//  ComicFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ComicFeatureNavStack: View {
    @State private var selection: ComicType = .story
    @AppStorage(.lastReadSpecialPage) private var lastReadSpecialPage: Int = 168
    @AppStorage(.lastReadMainStoryPage) private var lastReadMainStoryPage: Int = 0
    
    let chapters: [SwiftDataChapter]
    
    private var lastReadPage: Int {
        return selection == .story ? lastReadMainStoryPage : lastReadSpecialPage
    }
    
    private var currentChapter: SwiftDataChapter? {
        return chapters.first(where: { $0.containsPage(lastReadPage) })
    }
    
    private func updateLastReadPage(_ page: Int) {
        switch selection {
        case .story:
            lastReadMainStoryPage = page
        case .specials:
            lastReadSpecialPage = page
        }
    }
    
    var body: some View {
        NavStack(title: "DB Multiverse") {
            VStack {
                ComicTypePicker(selection: $selection)
                
                ChapterListView(
                    lastReadPage: lastReadPage,
                    sections: selection.chapterSections(chapters: chapters.filter({ $0 != currentChapter })),
                    currentChapter: currentChapter
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationDestination(for: SwiftDataChapter.self) { chapter in
                ChapterComicView(chapter: chapter, viewModel: .init(currentPageNumber: lastReadPage, loader: ChapterComicLoaderAdapter())) { currentPage in
                    updateLastReadPage(currentPage)
                }
                .navigationTitle("Chapter \(chapter.number)")
            }
        }
    }
}


// MARK: - Picker
struct ComicTypePicker: View {
    @Binding var selection: ComicType
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(ComicType.allCases, id: \.self) { type in
                Text(type.title)
                    .tag(type)
            }
        }
        .padding()
        .pickerStyle(.segmented)
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}



// MARK: - Extension Dependencies
extension SwiftDataChapter {
    var pageRangeText: String {
        return "Pages: \(startPage) - \(endPage)"
    }
}
