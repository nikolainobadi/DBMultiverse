//
//  ComicFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ComicFeatureNavStack: View {
    @Binding var lastReadPage: Int
    @State private var selection: ComicType = .story
    
    let chapters: [SwiftDataChapter]
    
    private var mainStoryChapters: [SwiftDataChapter] {
        return chapters.filter({ $0.universe == nil })
    }
    
    private var specialChapters: [SwiftDataChapter] {
        return chapters.filter({ $0.universe != nil })
    }
    
    var body: some View {
        NavStack(title: "DB Multiverse") {
            VStack {
                ComicTypePicker(selection: $selection)
                ChapterListView(chapters: mainStoryChapters, lastReadPage: lastReadPage)
                    .showingConditionalView(when: selection == .specials) {
                       SpecialChapterListView(chapters: specialChapters, lastReadPage: lastReadPage)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationDestination(for: SwiftDataChapter.self) { chapter in
                // TODO: - may have to create Bindable
                ChapterComicView(lastReadPage: $lastReadPage, chapter: chapter, viewModel: .init(currentPageNumber: lastReadPage, loader: ChapterComicLoaderAdapter()))
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


// MARK: - ChapterList
struct ChapterListView: View {
    let chapters: [SwiftDataChapter]
    let lastReadPage: Int
    
    private var currentChapter: SwiftDataChapter? {
        return chapters.first(where: { $0.isCurrentChapter(lastReadPage: lastReadPage) })
    }
    
    private var otherChapters: [SwiftDataChapter] {
        guard let currentChapter else {
            return chapters
        }
        
        return chapters.filter({ $0 != currentChapter })
    }
    
    var body: some View {
        List {
            CurrentChapterSection(chapter: currentChapter)
            
            Section("Chapters") {
                ForEach(otherChapters) { chapter in
                    ChapterRow(chapter: chapter)
                }
            }
        }
    }
}


struct SpecialChapterListView: View {
    let chapters: [SwiftDataChapter]
    let lastReadPage: Int
    
    private var currentChapter: SwiftDataChapter? {
        return chapters.first(where: { $0.isCurrentChapter(lastReadPage: lastReadPage) })
    }
    
    private var sections: [(key: String, chapters: [SwiftDataChapter])] {
        let grouped = Dictionary(grouping: chapters.filter { $0.universe != nil }, by: { $0.universe ?? "Unknown" })

        return grouped
            .sorted { lhs, rhs in
                extractUniverseNumber(lhs.key) < extractUniverseNumber(rhs.key)
            }
            .map { (key: $0.key, chapters: $0.value) }
    }

    private func extractUniverseNumber(_ title: String) -> Int {
        let pattern = #"Special Universe (\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        if let match = regex?.firstMatch(in: title, options: [], range: NSRange(title.startIndex..., in: title)),
           let range = Range(match.range(at: 1), in: title) {
            return Int(title[range]) ?? Int.max
        }
        return Int.max // Default to a high number if no match
    }
    
    var body: some View {
        List {
            CurrentChapterSection(chapter: currentChapter)
            
            ForEach(sections, id: \.key) { section in
                Section(section.key) {
                    ForEach(section.chapters) { chapter in
                        ChapterRow(chapter: chapter)
                    }
                }
            }
        }
    }
}


// MARK: - CurrentChapterSection
fileprivate struct CurrentChapterSection: View {
    let chapter: SwiftDataChapter?
    
    var body: some View {
        if let chapter {
            Section("Current Chapter") {
                ChapterRow(chapter: chapter)
            }
        }
    }
}


// MARK: - Row
fileprivate struct ChapterRow: View {
    let chapter: SwiftDataChapter
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(chapter.number) - \(chapter.name)")
                    .font(.headline)
            }
            
            Text(chapter.pageRangeText)
                .font(.subheadline)
            
            Text("Finished")
                .font(.caption)
                .foregroundStyle(.red)
                .onlyShow(when: chapter.didFinishReading)
        }
        .asNavLink(chapter)
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
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
extension SwiftDataChapter {
    var pageRangeText: String {
        return "Pages: \(startPage) - \(endPage)"
    }
    
    func isCurrentChapter(lastReadPage page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}
