//
//  SharedDataENV.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/14/24.
//

import Foundation

final class SharedDataENV: ObservableObject {
    @Published var completedChapterList: [String]
    
    private let delegate: ComicViewDelegate = ComicViewDelegateAdapter()
    private var pageInfoDict: [Chapter: [PageInfo]] = [:]
    
    init() {
        completedChapterList = UserDefaults.standard.array(forKey: .completedChapterListKey) as? [String] ?? []
    }
}


// MARK: - Actions
extension SharedDataENV {
    func finishChapter(number: String) {
        if !completedChapterList.contains(number) {
            completedChapterList.append(number)
            UserDefaults.standard.setValue(completedChapterList, forKey: .completedChapterListKey)
        }
    }
}


// MARK: - ComicViewDelegate
extension SharedDataENV: ComicViewDelegate {
    func loadChapterPages(_ chapter: Chapter) async throws -> [PageInfo] {
        print("loading from SharedDataENV")
        if let pages = pageInfoDict[chapter] {
            print("found existing pages")
            return pages
        }
        
        print("no pages found, attempting to load")
        let fetchedPages = try await delegate.loadChapterPages(chapter)
        
        print("caching chapters")
        pageInfoDict[chapter] = fetchedPages
        
        print("returning fetched pages")
        return fetchedPages
    }
}
