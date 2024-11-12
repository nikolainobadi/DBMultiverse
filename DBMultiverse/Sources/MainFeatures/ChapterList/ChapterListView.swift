//
//  ChapterListView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftUI
import SwiftSoup

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
                // TODO: - need to pass actual Chapter to view
                // this is so Chapter info can be used to perform image fetching
                ComicFeatureView(
                    lastReadPage: $lastReadPage,
                    viewModel: .init(
                        currentPageNumber: chapter.containsLastReadPage(lastReadPage) ? lastReadPage : chapter.startPage
                    )
                )
            }
        }
    }
}


// MARK: - List
struct ChapterListView: View {
    @StateObject var viewModel: ChapterListViewModel

    let lastReadPage: Int
    let onSelection: (Chapter) -> Void
    
    private var currentChapter: Chapter? {
        return viewModel.chapters.first(where: { $0.containsLastReadPage(lastReadPage) })
    }
    
    private var chaptersToDisplay: [Chapter] {
        guard let currentChapter else {
            return viewModel.chapters
        }
        
        return viewModel.chapters.filter({ $0 != currentChapter })
    }
    
    var body: some View {
        Group {
            if viewModel.chapters.isEmpty {
                Text("Loading Chapters...")
            } else {
                List {
                    if let currentChapter {
                        Section("Current Chapter") {
                            ChapterRow(chapter: currentChapter, isCurrentChapter: true)
                                .onTapGesture {
                                    onSelection(currentChapter)
                                }
                        }
                    }
                    
                    Section("Chapters") {
                        ForEach(chaptersToDisplay, id: \.startPage) { chapter in
                            ChapterRow(chapter: chapter, isCurrentChapter: chapter == currentChapter)
                                .onTapGesture {
                                    onSelection(chapter)
                                }
                        }
                    }
                }
            }
        }
        .task {
            try? await viewModel.loadChapters()
        }
    }
}


// MARK: - Row
struct ChapterRow: View {
    let chapter: Chapter
    let isCurrentChapter: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(chapter.name)
                    .font(.headline)
                
                Text("Pages: \(chapter.startPage) - \(chapter.endPage)")
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
    }
}


// MARK: - Preview
//#Preview {
//    ChapterListView()
//}
