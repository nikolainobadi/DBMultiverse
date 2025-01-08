//
//  ComicPageViewModel.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Combine
import Foundation

public final class ComicPageViewModel: ObservableObject {
    @Published var pages: [PageInfo]
    @Published var currentPageNumber: Int
    @Published var didFetchInitialPages = false
    
    private let chapter: Chapter
    private let delegate: ComicPageDelegate
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(chapter: Chapter, currentPageNumber: Int, delegate: ComicPageDelegate, pages: [PageInfo] = []) {
        self.pages = pages
        self.delegate = delegate
        self.chapter = chapter
        self.currentPageNumber = chapter.getCurrentPage(currentPage: currentPageNumber)
        
        self.startObservers()
    }
}


// MARK: - Display Data
public extension ComicPageViewModel {
    var currentPagePosition: PagePosition {
        let totalpages = chapter.totalPages
        let secondPage = currentPageInfo?.secondPageNumber
        let currentPageIndex = currentPageNumber - chapter.startPage
        
        return .init(page: currentPageIndex, secondPage: secondPage, totalPages: totalpages)
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
            let fetchedPages = try await delegate.loadPages(chapterNumber: chapter.number, pages: initialPages)
            
            await setPages(fetchedPages)
        }
    }
    
    func loadRemainingPages() {
        print("loading the remaining pages")
        Task {
            let allPages = Array(chapter.startPage...chapter.endPage)
            let fetchedPages = pages.map({ $0.pageNumber })
            let remainingPagesNumbers = allPages.filter({ !fetchedPages.contains($0) })
            
            do {
                let remainingList = try await delegate.loadPages(chapterNumber: chapter.number, pages: remainingPagesNumbers)
                
                await addRemainingPages(remainingList)
            } catch {
                // TODO: - need to handle this error
                print("Error loading remaining pages: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - PageDelegate
public extension ComicPageViewModel {
    func nextPage() {
        if let currentPageInfo, currentPageInfo.pageNumber < chapter.endPage {
            currentPageNumber = currentPageInfo.nextPage
        }
    }
    
    func previousPage() {
        if currentPageNumber > chapter.startPage {
            currentPageNumber -= 1
            
            if currentPageInfo == nil {
                currentPageNumber -= 1
            }
        }
    }
}


// MARK: - MainActor
@MainActor
private extension ComicPageViewModel {
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
}


// MARK: - Combine
private extension ComicPageViewModel {
    func startObservers() {
        $currentPageNumber
            .sink { [unowned self] newPageNumber in
                delegate.updateCurrentPageNumber(newPageNumber)
            }
            .store(in: &cancellables)
        
        $didFetchInitialPages
            .first(where: { $0 })
            .sink { [unowned self] _ in
                loadRemainingPages()
            }
            .store(in: &cancellables)
    }
}


// MARK: - Dependencies
public protocol ComicPageDelegate {
    func updateCurrentPageNumber(_ pageNumber: Int)
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo]
}


// MARK: - Extension Dependencies
fileprivate extension Chapter {
    var totalPages: Int {
        return endPage - startPage
    }
    
    func getCurrentPage(currentPage: Int) -> Int {
        return lastReadPage ?? (containsPage(currentPage) ? currentPage : startPage)
    }
}

fileprivate extension PageInfo {
    var nextPage: Int {
        guard let secondPageNumber else {
            return pageNumber + 1
        }
        
        return secondPageNumber + 1
    }
}
