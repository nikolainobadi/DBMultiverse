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
    
    let chapters: [SwiftDataChapter]
    let lastReadPage: Int
    
    var body: some View {
        NavStack(title: "DB Multiverse") {
            VStack {
                ComicTypePicker(selection: $selection)
                ChapterListView(chapters: chapters, lastReadPage: lastReadPage)
                    .showingConditionalView(when: selection == .specials) {
                        Text("Specials coming soon...")
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationDestination(for: SwiftDataChapter.self) { chapter in
                Text(chapter.name)
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
