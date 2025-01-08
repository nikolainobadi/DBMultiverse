//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

public final class ComicPageViewModel: ObservableObject {
    @Published var pages: [ComicPage]
    @Published var currentPageNumber: Int
    @Published var didFetchInitialPages = false
    
    private let loader: ComicPageLoader
    
    public init(currentPageNumber: Int, loader: ComicPageLoader, pages: [ComicPage] = []) {
        self.pages = pages
        self.loader = loader
        self.currentPageNumber = currentPageNumber
    }
}


// MARK: - Display Data
public extension ComicPageViewModel {
    var currentPage: ComicPage? {
        return nil
    }
}


// MARK: - Actions
extension ComicPageViewModel {
    func loadData() async throws {
        // TODO: -
    }
    
    func loadRemainingPages() {
        // TODO: -
    }
}


// MARK: - PageDelegate
public extension ComicPageViewModel {
    func nextPage() {
        // TODO: -
    }
    
    func previousPage() {
        // TODO: -
    }
}


// MARK: - Dependencies
public protocol ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [ComicPage]
}
