//
//  ChapterListView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import SwiftUI

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
                    .font(.title)
            } else {
                List {
                    if let currentChapter {
                        Section("Current Chapter") {
                            ChapterRow(chapter: currentChapter, isCurrentChapter: true)
                                .onTapGesture {
                                    print("selected chapter:", currentChapter.number)
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
    @EnvironmentObject var sharedDataENV: SharedDataENV
    
    let chapter: Chapter
    let isCurrentChapter: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Text(chapter.name)
                    .font(.headline)
                
                Text("Pages: \(chapter.startPage) - \(chapter.endPage)")
                    .font(.subheadline)
                
                if sharedDataENV.completedChapterList.contains(chapter.number) {
                    Text("Finished Chapter")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
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
