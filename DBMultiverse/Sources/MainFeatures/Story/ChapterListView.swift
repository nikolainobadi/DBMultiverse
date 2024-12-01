//
//  ChapterListView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftUI
import NnSwiftUIKit

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
        List {
            if let currentChapter {
                Section("Current Chapter") {
                    ChapterRow(chapter: currentChapter, isCurrentChapter: true)
                        .swipeActions(edge: .leading) {
                            Button(action: { viewModel.unreadChapter(currentChapter) }) {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            }
                            .onlyShow(when: currentChapter.didRead)
                        }
                        .tappable(withChevron: true) {
                            onSelection(currentChapter)
                        }
                }
            }
            
            Section("Chapters") {
                ForEach(chaptersToDisplay, id: \.startPage) { chapter in
                    ChapterRow(chapter: chapter, isCurrentChapter: chapter == currentChapter)
                        .tappable(withChevron: true) {
                            onSelection(chapter)
                        }
                }
            }
        }
        .showingConditionalView(when: viewModel.chapters.isEmpty) {
            Text("Loading Chapters...")
                .font(.title)
        }
    }
}


// MARK: - Row
struct ChapterRow: View {
    @EnvironmentObject var sharedDataENV: SharedDataENV
    
    let chapter: Chapter
    let isCurrentChapter: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(chapter.name)
                .font(.headline)
            
            Text("Pages: \(chapter.startPage) - \(chapter.endPage)")
                .font(.subheadline)
            
            Text("Finished Chapter")
                .font(.caption)
                .foregroundStyle(.red)
                .onlyShow(when: sharedDataENV.completedChapterList.contains(chapter.number))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// MARK: - Preview
//#Preview {
//    ChapterListView()
//}
