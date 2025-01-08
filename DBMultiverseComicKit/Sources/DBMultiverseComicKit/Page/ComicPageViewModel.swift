//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import Foundation

final class ComicPageViewModel: ObservableObject {
    @Published var pages: [ComicPage] = []
    @Published var didFetchInitialPages = false
    
    private let loader: ComicPageLoader
    
    init(loader: ComicPageLoader) {
        self.loader = loader
    }
}


// MARK: - Display Data
extension ComicPageViewModel {
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


// MARK: - Dependencies
public protocol ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [ComicPage]
}
