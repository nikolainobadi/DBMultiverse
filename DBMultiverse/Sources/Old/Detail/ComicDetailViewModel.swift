//
//  ChapterComicViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import Foundation
import DBMultiverseComicKit

/// ViewModel for managing the state and logic of comic chapters.
final class ComicDetailViewModel: ObservableObject {
    /// List of pages in the current comic chapter.
    @Published var pages: [PageInfo]
    
    /// The current page number being viewed.
    @Published var currentPageNumber: Int
    
    /// Indicates whether the pages have been fetched.
    @Published var didFetchPages = false

    /// Loader responsible for fetching pages.
    private let loader: ChapterComicLoader

    /// Initializes the ViewModel with the current page number and loader.
    /// - Parameters:
    ///   - currentPageNumber: The initial page number.
    ///   - loader: The loader for fetching pages.
    ///   - pages: Preloaded pages (default is an empty array).
    init(currentPageNumber: Int, loader: ChapterComicLoader, pages: [PageInfo] = []) {
        self.currentPageNumber = currentPageNumber
        self.loader = loader
        self.pages = pages
    }
}


// MARK: - DisplayData
extension ComicDetailViewModel {
    /// Retrieves the current page information.
    var currentPageInfo: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
}


// MARK: - Actions
extension ComicDetailViewModel {
    /// Moves to the previous page if not already at the start.
    /// - Parameter start: The start page of the chapter.
    func previousPage(start: Int) {
        if currentPageNumber > start {
            currentPageNumber -= 1
            
            if currentPageInfo == nil {
                currentPageNumber -= 1
            }
        }
    }
    
    /// Moves to the next page if not already at the end.
    /// - Parameter end: The end page of the chapter.
    func nextPage(end: Int) {
        if let currentPageInfo, currentPageNumber < end  {
            currentPageNumber = currentPageInfo.nextPage
        }
    }
    
    /// Retrieves the current position in the chapter as a string.
    /// - Parameter info: Information about the chapter.
    /// - Returns: A string representing the current page position in the format "X/Y" or "X-X+1/Y".
    func getCurrentPagePosition(chapterInfo info: ChapterInfo) -> String {
        let totalPages = info.endPage - info.startPage
        let currentPageIndex = currentPageNumber - info.startPage

        if currentPageInfo?.secondPageNumber == nil {
            // Single-page format: "X/Y"
            return "\(currentPageIndex)/\(totalPages)"
        }

        // Double-page format: "X-X+1/Y"
        return "\(currentPageIndex)-\(currentPageIndex + 1)/\(totalPages)"
    }
    
    /// Fetches the initial pages of the chapter.
        /// - Parameter info: Information about the chapter.
    func loadInitialPages(for info: ChapterInfo) async throws {
        if didFetchPages {
            return
        }

        let startPage = info.lastReadPage ?? info.startPage
        let initialPages = Array(startPage...(min(startPage + 4, info.endPage)))
        let pages = try await loader.loadPages(chapterNumber: info.number, pages: initialPages)
        
        await setPages(pages)
    }
    
    /// Fetches the remaining pages of the chapter.
        /// - Parameter info: Information about the chapter.
    func loadRemainingPages(for info: ChapterInfo) {
        Task {
            let allPages = Array(info.startPage...info.endPage)
            let fetchedPages = pages.map({ $0.pageNumber })
            let remainingPages = allPages.filter({ !fetchedPages.contains($0) })
            
            do {
                let remainingPageInfos = try await loader.loadPages(chapterNumber: info.number, pages: remainingPages)
                
                await addRemainingPages(remainingPageInfos)
            } catch {
                // TODO: - need to handle this error
                print("Error loading remaining pages: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - MainActor
@MainActor
private extension ComicDetailViewModel {
    /// Sets the pages and marks them as fetched.
    /// - Parameter pages: The pages to set.
    func setPages(_ pages: [PageInfo]) {
        self.pages = pages
        self.didFetchPages = true
    }

    /// Adds remaining pages to the list.
    /// - Parameter remaining: The remaining pages to add.
    func addRemainingPages(_ remaining: [PageInfo]) {
        let uniquePages = remaining.filter { newPage in
            !pages.contains { $0.pageNumber == newPage.pageNumber }
        }

        pages.append(contentsOf: uniquePages)
        pages.sort { $0.pageNumber < $1.pageNumber }
    }
}


// MARK: - Dependencies
/// Protocol defining a loader for comic pages.
protocol ChapterComicLoader {
    /// Loads pages for a specific chapter and page range.
    /// - Parameters:
    ///   - chapterNumber: The chapter number.
    ///   - pages: The range of pages to load.
    /// - Returns: A list of page information.
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo]
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
