//
//  SharedDataENV.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/14/24.
//

import Foundation

final class SharedDataENV: ObservableObject {
    @Published var specials: [Special] = []
    @Published var storyChapters: [Chapter] = []
    @Published var completedChapterList: [String]
    
    private let defaults: UserDefaults
    private let delegate: ComicViewDelegate = ComicViewDelegateAdapter()
    private var pageInfoDict: [Chapter: [OldPageInfo]] = [:]
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.completedChapterList = defaults.array(forKey: .completedChapterListKey) as? [String] ?? []
    }
}


// MARK: - Actions
extension SharedDataENV {
    func finishChapter(number: String) {
        if !completedChapterList.contains(number) {
            completedChapterList.append(number)
            defaults.setValue(completedChapterList, forKey: .completedChapterListKey)
        }
    }
}


// MARK: - ComicViewDelegate
extension SharedDataENV: ComicViewDelegate {
    func loadChapterPages(_ chapter: Chapter) async throws -> [OldPageInfo] {
        if let pages = pageInfoDict[chapter] {
            return pages
        }
        
        let fetchedPages = try await delegate.loadChapterPages(chapter)
        
        pageInfoDict[chapter] = fetchedPages
        
        return fetchedPages
    }
}
