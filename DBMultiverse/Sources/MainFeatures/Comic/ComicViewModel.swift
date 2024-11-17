//
//  ComicViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import Foundation

final class ComicViewModel: ObservableObject {
    @Published var currentPageNumber: Int
    @Published var pages: [PageInfo] = []
    
    private let chapter: Chapter
    private let delegate: ComicViewDelegate
    private let onChapterFinished: (String) -> Void
    
    init(chapter: Chapter, currentPageNumber: Int, delegate: ComicViewDelegate, onChapterFinished: @escaping (String) -> Void) {
        self.chapter = chapter
        self.delegate = delegate
        self.currentPageNumber = currentPageNumber
        self.onChapterFinished = onChapterFinished
    }
}


// MARK: - DisplayData
extension ComicViewModel {
    var isLastPage: Bool {
        guard let currentPage, let pageNumber = Int(currentPage.pageNumber) else {
            return false
        }
        
        return pageNumber == chapter.endPage
    }
    
    var currentPage: PageInfo? {
        return pages.first(where: { $0.pageNumber == "\(currentPageNumber)" })
    }
    
    var previousButtonDisabled: Bool {
        return currentPageNumber <= chapter.startPage
    }
    
    var nextButtonDisabled: Bool {
        return currentPageNumber >= chapter.endPage
    }
    
    var currentPagePosition: String {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let currentPageIndex = currentPageNumber - chapter.startPage + 1
        
        return "\(currentPageIndex)/\(totalPages)"
    }
}


// MARK: - Actions
extension ComicViewModel {
    func loadPages() async throws {
        print("preparing to load pages for \(chapter.number)")
        let pages = try await delegate.loadChapterPages(chapter)
        
        await setPages(pages)
    }
    
    func previousPage() {
        if currentPageNumber > 0 {
            currentPageNumber -= 1
        }
    }
    
    func nextPage() {
        if currentPageNumber < chapter.endPage {
            currentPageNumber += 1
        }
    }
    
    func finishChapter() {
        onChapterFinished(chapter.number)
    }
}


// MARK: MainActor
@MainActor
private extension ComicViewModel {
    func setPages(_ pages: [PageInfo]) {
        self.pages = pages
        
        if !pages.compactMap({ Int($0.pageNumber) }).contains(currentPageNumber) {
            currentPageNumber = chapter.startPage
        }
    }
}


// MARK: - Dependencies
protocol ComicViewDelegate {
    func loadChapterPages(_ chapter: Chapter) async throws -> [PageInfo]
}

struct PageInfo {
    let imageData: Data
    let chapter: String
    let pageNumber: String
}

extension PageInfo {
    var title: String {
        if pageNumber == "0" {
            return ""
        }
        
        return "Chapter \(chapter) page \(pageNumber)"
    }
}


// MARK: - Exension Dependeencies
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
