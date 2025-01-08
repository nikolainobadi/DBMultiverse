//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import UIKit
import Foundation

public final class ComicPageViewModel: ObservableObject {
    @Published var pages: [PageInfo]
    @Published var currentPageNumber: Int
    @Published var didFetchInitialPages = false
    
    private let chapter: Chapter
    private let loader: ComicPageLoader
    
    public init(chapter: Chapter, currentPageNumber: Int, loader: ComicPageLoader, pages: [PageInfo] = []) {
        self.pages = pages
        self.loader = loader
        self.chapter = chapter
        self.currentPageNumber = currentPageNumber
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
        guard let currentPagePosition, let currentPageInfo, let image = UIImage(data: currentPageInfo.imageData) else {
            return nil
        }
        
        return .init(number: currentPageInfo.pageNumber, chapterName: chapter.name, pagePosition: currentPagePosition, image: image)
    }
}


// MARK: - Actions
public extension ComicPageViewModel {
    func loadData() async throws {
        if !didFetchInitialPages {
            let startPage = chapter.lastReadPage ?? chapter.startPage
            let initialPages = Array(startPage...(min(startPage + 4, chapter.endPage)))
            let fetchedPages = try await loader.loadPages(chapterNumber: chapter.number, pages: initialPages)
            
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


@MainActor
private extension ComicPageViewModel {
    func setPages(_ pages: [PageInfo]) {
        self.pages = pages
        self.didFetchInitialPages = true
    }
}


// MARK: - Dependencies
public protocol ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo]
}

public struct PageInfo {
    public let chapter: Int
    public let pageNumber: Int
    public let secondPageNumber: Int?
    public let imageData: Data
    
    public init(chapter: Int, pageNumber: Int, secondPageNumber: Int?, imageData: Data) {
        self.chapter = chapter
        self.pageNumber = pageNumber
        self.secondPageNumber = secondPageNumber
        self.imageData = imageData
    }
}

extension Chapter {
    var totalPages: Int {
        return endPage - startPage
    }
}

// MARK: - Extension Dependencies
fileprivate extension PageInfo {
    var nextPage: Int {
        guard let secondPageNumber else {
            return pageNumber + 1
        }
        
        return secondPageNumber + 1
    }
}

