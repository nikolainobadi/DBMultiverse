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
    @Published private var didFetchPages = false
    
    private let loader: ChapterComicLoader
    
    init(currentPageNumber: Int, loader: ChapterComicLoader) {
        self.currentPageNumber = currentPageNumber
        self.loader = loader
    }
}


// MARK: - DisplayData
extension ChapterComicViewModel {
    var currentPage: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
}


// MARK: - Actions
extension ChapterComicViewModel {
    func getCurrentPagePosition(chapter: SwiftDataChapter) -> String {
        let totalPages = chapter.endPage - chapter.startPage
        let currentPageIndex = currentPageNumber - chapter.startPage
        
        return "\(currentPageIndex)/\(totalPages)"
    }
    
    func loadPages(for chapter: SwiftDataChapter) async throws {
        if didFetchPages {
            return
        }
        
        let pages = try await loader.loadPages(chapter: chapter)
        
        await setPages(pages, firstPage: chapter.startPage)
    }
    
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
}


// MARK: MainActor
@MainActor
private extension ChapterComicViewModel {
    func setPages(_ pages: [PageInfo], firstPage: Int) {
        self.pages = pages
        self.didFetchPages = true
        
        if !pages.compactMap({ Int($0.pageNumber) }).contains(currentPageNumber) {
            currentPageNumber = firstPage
        }
    }
}


// MARK: - Dependencies
protocol ChapterComicLoader {
    func loadPages(chapter: SwiftDataChapter) async throws -> [PageInfo]
}
