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
                Text("Comic for \(chapter.name)")
            }
        }
    }
}

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


// MARK: - ViewModel
final class ChapterListViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    
    private let loader: ChapterLoader
    
    init(loader: ChapterLoader = ChapterLoaderAdapter()) {
        self.loader = loader
    }
}

extension ChapterListViewModel {
    func loadChapters() async throws {
        let chapters = try await loader.loadChapters()
        
        await setChapters(chapters)
    }
}


// MARK: - MainActor
@MainActor
private extension ChapterListViewModel {
    func setChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
}


// MARK: - Dependencies
protocol ChapterLoader {
    func loadChapters() async throws -> [Chapter]
}

struct Chapter: Hashable {
    let name: String
    let startPage: Int
    let endPage: Int
    
    func containsLastReadPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}


final class ChapterLoaderAdapter {
    private let url = URL(string: "https://www.dragonball-multiverse.com/en/chapters.html?comic=page&chaptersmode=1")!
}


// MARK: - Loader
extension ChapterLoaderAdapter: ChapterLoader {
    func loadChapters() async throws -> [Chapter] {
        guard let html = try await loadHTML() else {
            return []
        }
        
        return try parseHTML(html)
    }
}


// MARK: - Private Methods
private extension ChapterLoaderAdapter {
    func loadHTML() async throws -> String? {
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(data: data, encoding: .utf8)
    }
    
    func parseHTML(_ html: String) throws -> [Chapter] {
        let document = try SwiftSoup.parse(html)
        let chapterElements = try document.select("div.cadrelect.chapter")
        
        var loadedChapters: [Chapter] = []

        for chapterElement in chapterElements {
            // Extract chapter name
            let chapterTitle = try chapterElement.select("h4").text()
            
            // Extract start and end pages
            let pageLinks = try chapterElement.select("p a")
            if let startPageText = try? pageLinks.first()?.text(),
               let endPageText = try? pageLinks.last()?.text(),
               let startPage = Int(startPageText),
               let endPage = Int(endPageText) {
                
                let chapter = Chapter(name: chapterTitle, startPage: startPage, endPage: endPage)
                loadedChapters.append(chapter)
            }
        }

        return loadedChapters
    }
}
