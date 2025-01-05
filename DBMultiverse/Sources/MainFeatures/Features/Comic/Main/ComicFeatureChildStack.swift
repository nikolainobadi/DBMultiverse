//
//  ComicFeatureChildStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ComicFeatureChildStack: View {
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
        VStack {
            ComicTypePicker(selection: $selection)
                .showingConditionalView(when: isPad) {
                    FancyPicker(selection: $selection)
                }
            
            ChapterListView(
                lastReadPage: lastReadPage,
                sections: selection.chapterSections(chapters: chapters.filter({ $0 != currentChapter })),
                currentChapter: currentChapter
            )
        }
        .animation(.smooth, value: selection)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationDestination(for: SwiftDataChapter.self) { chapter in
            ComicDetailView(chapter: chapter, viewModel: .init(currentPageNumber: chapter.lastReadPage ?? chapter.startPage, loader: ChapterComicLoaderAdapter())) { currentPage in
                updateLastReadPage(currentPage)
            }
            .navigationTitle("Chapter \(chapter.number)")
        }
    }
}


// MARK: - Picker
struct ComicTypePicker: View {
    @Binding var selection: ComicType
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(ComicType.allCases, id: \.self) { type in
                Text(type.title)
                    .withFont(textColor: selection == type ? Color.white : type.color)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(selection == type ? type.color : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selection = type
                    }
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    MainFeaturesView()
        .withPreviewModifiers()
}


// MARK: - Extension Dependencies
extension SwiftDataChapter {
    var pageRangeText: String {
        return "Pages: \(startPage) - \(endPage)"
    }
}
