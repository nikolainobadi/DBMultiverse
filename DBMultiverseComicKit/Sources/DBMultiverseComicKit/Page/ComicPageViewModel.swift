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
        self.currentPageNumber = currentPageNumber
        
        self.startObservers()
    }
}


// MARK: - Display Data
public extension ComicPageViewModel {
    var currentPagePosition: PagePosition? {
        return .init(page: currentPageNumber - chapter.startPage, totalPages: chapter.totalPages)
    }
    
    var currentPageInfo: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
    
    var currentPage: ComicPage? {
        guard let currentPagePosition, let currentPageInfo else {
            return nil
        }
        
        return .init(number: currentPageInfo.pageNumber, chapterName: chapter.name, pagePosition: currentPagePosition, imageData: currentPageInfo.imageData)
    }
}


// MARK: - Actions
public extension ComicPageViewModel {
    func loadData() async throws {
        if !didFetchInitialPages {
            let startPage = chapter.lastReadPage ?? chapter.startPage
            let initialPages = Array(startPage...(min(startPage + 4, chapter.endPage)))
            let fetchedPages = try await delegate.loadPages(chapterNumber: chapter.number, pages: initialPages)
            
            print("fetched \(fetchedPages.count) pages, currentPageNumber: \(currentPageNumber)")
            
            await setPages(fetchedPages)
        }
    }
    
    func loadRemainingPages() {
//        let allPages = Array(chapter.startPage...chapter.endPage)
//        let fetchedPages = pages.map({ $0.number })
//        let remainingPages = allPages.filter({ !fetchedPages.contains($0) })
//        
//        let infoList = try await
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
}


// MARK: - Combine
private extension ComicPageViewModel {
    func startObservers() {
        $currentPageNumber
            .dropFirst()
            .sink { [unowned self] newPageNumber in
                delegate.updateCurrentPageNumber(newPageNumber)
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
}

fileprivate extension PageInfo {
    var nextPage: Int {
        guard let secondPageNumber else {
            return pageNumber + 1
        }
        
        return secondPageNumber + 1
    }
}
