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
    
    private var currentChapter: SwiftDataChapter? {
        return chapters.first(where: { $0.isCurrentChapter(lastReadPage: lastReadPage) })
    }
    
    var body: some View {
        NavStack(title: "DB Multiverse") {
            VStack {
                ComicTypePicker(selection: $selection)
                
                NewChapterListView(
                    lastReadPage: lastReadPage,
                    sections: selection.chapterSections(chapters: chapters.filter({ $0 != currentChapter })),
                    currentChapter: currentChapter
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationDestination(for: SwiftDataChapter.self) { chapter in
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

struct NewChapterListView: View {
    let lastReadPage: Int
    let sections: [ChapterSection]
    let currentChapter: SwiftDataChapter?
    
    var body: some View {
        List {
            CurrentChapterSection(chapter: currentChapter)
            
            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.chapters) { chapter in
                        ChapterRow(chapter: chapter)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ChapterSection {
    let title: String
    let chapters: [SwiftDataChapter]
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
        .listStyle(.plain)
    }
}


struct SpecialChapterListView: View {
    let chapters: [SwiftDataChapter]
    let lastReadPage: Int
    
//    private var currentChapter: SwiftDataChapter? {
//        return chapters.first(where: { $0.isCurrentChapter(lastReadPage: lastReadPage) })
//    }
//    
//    private var sections: [(key: String, chapters: [SwiftDataChapter])] {
//        let grouped = Dictionary(grouping: chapters.filter { $0.universe != nil }, by: { $0.universe ?? "Unknown" })
//
//        return grouped
//            .sorted { lhs, rhs in
//                extractUniverseNumber(lhs.key) < extractUniverseNumber(rhs.key)
//            }
//            .map { (key: $0.key, chapters: $0.value) }
//    }
//
//    private func extractUniverseNumber(_ title: String) -> Int {
//        let pattern = #"Special Universe (\d+)"#
//        let regex = try? NSRegularExpression(pattern: pattern, options: [])
//        if let match = regex?.firstMatch(in: title, options: [], range: NSRange(title.startIndex..., in: title)),
//           let range = Range(match.range(at: 1), in: title) {
//            return Int(title[range]) ?? Int.max
//        }
//        return Int.max // Default to a high number if no match
//    }
    
    var body: some View {
        List {
//            CurrentChapterSection(chapter: currentChapter)
//            
//            ForEach(sections, id: \.key) { section in
//                Section(section.key) {
//                    ForEach(section.chapters) { chapter in
//                        ChapterRow(chapter: chapter)
//                    }
//                }
//            }
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
        HStack {
            CustomAsyncImage(url: URL(string: .makeFullURLString(suffix: chapter.coverImageURL)))
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(chapter.number) - \(chapter.name)")
                    .font(.headline)
                
                Text(chapter.pageRangeText)
                    .font(.subheadline)
                
                if chapter.didFinishReading {
                    Text("Finished")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    
    func chapterSections(chapters: [SwiftDataChapter]) -> [ChapterSection] {
        switch self {
        case .story:
            return [.init(title: "Main Story Chapters", chapters: chapters.filter({ $0.universe == nil }))]
        case .specials:
            return Dictionary(grouping: chapters.filter({ $0.universe != nil }), by: { $0.universe! })
                .sorted(by: { $0.key < $1.key })
                .map({ .init(title: "Universe \($0.key)", chapters: $0.value) })
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

import SwiftUI

struct CustomAsyncImage: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    
    init(url: URL?, width: CGFloat = 50, height: CGFloat = 70) {
        self.url = url
        self.width = width
        self.height = height
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                // Placeholder while loading
                placeholder
            case .success(let image):
                // Display the image
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: height)
                    .cornerRadius(8)
                    .clipped()
            case .failure:
                // Fallback for a failed load
                failurePlaceholder
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .cornerRadius(8)
    }
    
    private var failurePlaceholder: some View {
        Rectangle()
            .fill(Color.red.opacity(0.3))
            .frame(width: width, height: height)
            .cornerRadius(8)
    }
}
