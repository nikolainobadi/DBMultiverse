//
//  ChapterComicViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import Foundation

final class ChapterComicViewModel: ObservableObject {
    @Published var pages: [PageInfo] = []
    @Published var currentPageNumber: Int
    @Published var didFetchPages = false
    
    private let loader: ChapterComicLoader
    
    init(currentPageNumber: Int, loader: ChapterComicLoader) {
        self.currentPageNumber = currentPageNumber
        self.loader = loader
    }
}


// MARK: - DisplayData
extension ChapterComicViewModel {
    var currentPageInfo: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
}


// MARK: - Actions
extension ChapterComicViewModel {
    func previousPage(start: Int) {
        if currentPageNumber > start {
            currentPageNumber -= 1
        }
    }
    
    func nextPage(end: Int) {
        if currentPageNumber < end {
            currentPageNumber += 1
        }
    }
    
    func getCurrentPagePosition(chapter: SwiftDataChapter) -> String {
        let totalPages = chapter.endPage - chapter.startPage
        let currentPageIndex = currentPageNumber - chapter.startPage
        
        return "\(currentPageIndex)/\(totalPages)"
    }
    
    func loadInitialPages(for chapter: SwiftDataChapter) async throws {
        if didFetchPages {
            return
        }

        let startPage = chapter.lastReadPage ?? chapter.startPage
        let initialPages = Array(startPage...(min(startPage + 4, chapter.endPage)))
        let pages = try await loader.loadPages(chapterNumber: chapter.number, pages: initialPages)
        
        await setPages(pages)
    }
    
    func loadRemainingPages(for chapter: SwiftDataChapter) {
        Task {
            let allPages = Array(chapter.startPage...chapter.endPage)
            let fetchedPages = pages.map({ $0.pageNumber })
            let remainingPages = allPages.filter({ !fetchedPages.contains($0) })
            
            do {
                let remainingPageInfos = try await loader.loadPages(chapterNumber: chapter.number, pages: remainingPages)
                
                await addRemainingPages(remainingPageInfos)
            } catch {
                // TODO: - need to handle this error
                print("Error loading remaining pages: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: MainActor
@MainActor
private extension ChapterComicViewModel {
    func setPages(_ pages: [PageInfo]) {
        self.pages = pages
        self.didFetchPages = true
    }
    
    func addRemainingPages(_ remaining: [PageInfo]) {
        let uniquePages = remaining.filter { newPage in
            !pages.contains { $0.pageNumber == newPage.pageNumber }
        }
        
        pages.append(contentsOf: uniquePages)
        pages.sort { $0.pageNumber < $1.pageNumber }
    }

}


// MARK: - Dependencies
protocol ChapterComicLoader {
    func loadPages(chapter: SwiftDataChapter) async throws -> [PageInfo]
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo]
    func loadPages(chapterNumber: Int, start: Int, end: Int) async throws -> [PageInfo]
}
