//
//  ComicPageViewModel.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

@MainActor
public final class ComicPageViewModel: ObservableObject {
    @Published var pages: [PageInfo]
    @Published var currentPageNumber: Int
    @Published private(set) var didFetchInitialPages = false
    
    private let chapter: Chapter
    private let delegate: ComicPageDelegate
    
    public init(chapter: Chapter, currentPageNumber: Int, delegate: ComicPageDelegate, pages: [PageInfo] = []) {
        self.pages = pages
        self.delegate = delegate
        self.chapter = chapter
        self.currentPageNumber = chapter.getCurrentPage(currentPage: currentPageNumber)
    }
}


// MARK: - Display Data
public extension ComicPageViewModel {
    var currentPagePosition: PagePosition {
        return .init(page: currentPageNumber, secondPage: currentPageInfo?.secondPageNumber, endPage: chapter.endPage)
    }
    
    var currentPageInfo: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
    
    var currentPage: ComicPage? {
        guard let currentPageInfo else {
            return nil
        }
        
        return .init(
            number: currentPageInfo.pageNumber,
            chapterName: chapter.name,
            pagePosition: currentPagePosition,
            imageData: currentPageInfo.imageData
        )
    }
}


// MARK: - Actions
public extension ComicPageViewModel {
    func loadData() async throws {
        if !didFetchInitialPages {
            let initialPages = Array(currentPageNumber...(min(currentPageNumber + 4, chapter.endPage)))
            let fetchedPages = try await delegate.loadPages(initialPages)
            
            setPages(fetchedPages)
            await loadRemainingPages()
        }
    }
}


// MARK: - PageDelegate
public extension ComicPageViewModel {
    func nextPage() {
        if let currentPageInfo, currentPageInfo.pageNumber < chapter.endPage {
            updatePageNumber(currentPageInfo.nextPage)
        }
    }
    
    func previousPage() {
        if currentPageNumber > chapter.startPage {
            var newPageNumber = currentPageNumber - 1
            
            if pages.first(where: { $0.pageNumber == newPageNumber }) == nil {
                newPageNumber -= 1
            }
            
            updatePageNumber(newPageNumber)
        }
    }
}


// MARK: - Private Methods
private extension ComicPageViewModel {
    func updatePageNumber(_ newPageNumber: Int) {
        currentPageNumber = newPageNumber
        delegate.updateCurrentPageNumber(newPageNumber)
    }
    
    func cacheChapterCoverImage() {
        if let chapterCoverPage = pages.first(where: { $0.pageNumber == chapter.startPage }) {
            delegate.saveChapterCoverPage(chapterCoverPage)
        }
    }
    
    func setPages(_ pages: [PageInfo]) {
        self.pages = pages
        self.didFetchInitialPages = true
    }
    
    func addRemainingPages(_ remaining: [PageInfo]) {
        let uniquePages = remaining.filter { newPage in
            !pages.contains { $0.pageNumber == newPage.pageNumber }
        }

        pages.append(contentsOf: uniquePages)
        pages.sort { $0.pageNumber < $1.pageNumber }
    }
    
    func loadRemainingPages() async {
        let allPages = Array(chapter.startPage...chapter.endPage)
        let fetchedPages = pages.map({ $0.pageNumber })
        let remainingPagesNumbers = allPages.filter({ !fetchedPages.contains($0) })
        
        do {
            let remainingList = try await delegate.loadPages(remainingPagesNumbers)
            
            addRemainingPages(remainingList)
            cacheChapterCoverImage()
        } catch {
            // TODO: - need to handle this error
            print("Error loading remaining pages: \(error.localizedDescription)")
        }
    }
}


// MARK: - Dependencies
public protocol ComicPageDelegate: Sendable {
    func saveChapterCoverPage(_ info: PageInfo)
    func updateCurrentPageNumber(_ pageNumber: Int)
    func loadPages(_ pages: [Int]) async throws -> [PageInfo]
}


// MARK: - Extension Dependencies
private extension Chapter {
    var totalPages: Int {
        return endPage - startPage
    }
    
    func getCurrentPage(currentPage: Int) -> Int {
        return lastReadPage ?? (containsPage(currentPage) ? currentPage : startPage)
    }
}

private extension PageInfo {
    var nextPage: Int {
        guard let secondPageNumber else {
            return pageNumber + 1
        }
        
        return secondPageNumber + 1
    }
}
