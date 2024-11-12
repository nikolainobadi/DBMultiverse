//
//  ChapterListViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import Foundation

final class ChapterListViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    
    private let loader: ChapterLoader
    
    init(loader: ChapterLoader = ChapterLoaderAdapter()) {
        self.loader = loader
    }
}

extension ChapterListViewModel {
    func loadChapters() async throws {
        let chapters = try await loader.loadChapters()
        
        await setChapters(chapters)
    }
}


// MARK: - MainActor
@MainActor
private extension ChapterListViewModel {
    func setChapters(_ chapters: [Chapter]) {
        self.chapters = chapters
    }
}


// MARK: - Dependencies
protocol ChapterLoader {
    func loadChapters() async throws -> [Chapter]
}
