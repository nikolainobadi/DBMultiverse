//
//  ComicPageManager.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import DBMultiverseComicKit

final class ComicPageManager {
    private let chapter: Chapter
    private let imageCache: ComicImageCache
    private let networkService: ComicPageNetworkService
    private let chapterProgressHandler: ChapterProgressHandler
    
    init(chapter: Chapter, imageCache: ComicImageCache, networkService: ComicPageNetworkService, chapterProgressHandler: ChapterProgressHandler) {
        self.chapter = chapter
        self.imageCache = imageCache
        self.networkService = networkService
        self.chapterProgressHandler = chapterProgressHandler
    }
}


// MARK: - Delegate
extension ComicPageManager: ComicPageDelegate {
    func saveChapterCoverPage(_ info: PageInfo) {
        let readProgress = calculateProgress(page: info.pageNumber)
        let metadata = CoverImageMetaData(chapterName: chapter.name, chapterNumber: chapter.number, readProgress: readProgress)
        
        try? imageCache.saveChapterCoverImage(imageData: info.imageData, metadata: metadata)
    }
    
    func updateCurrentPageNumber(_ pageNumber: Int) {
        updateChapterProgress(lastReadPage: pageNumber)
        imageCache.updateCurrentPageNumber(pageNumber, readProgress: calculateProgress(page: pageNumber))
    }

    func loadPages(_ pages: [Int]) async throws -> [PageInfo] {
        var infoList = [PageInfo]()
        
        for page in pages {
            if !page.isSecondPage {
                if let cachedInfo = imageCache.loadCachedImage(chapter: chapter.number, page: page) {
                    print("found page \(page) in cache for chapter \(chapter.number)")
                    infoList.append(cachedInfo)
                } else if let fetchedInfo = await fetchPageInfo(page: page) {
                    infoList.append(fetchedInfo)
                    imageCache.savePageImage(pageInfo: fetchedInfo)
                }
            }
        }
        
        return infoList
    }
}


// MARK: - Private Methods
private extension ComicPageManager {
    func updateChapterProgress(lastReadPage: Int) {
        chapterProgressHandler.updateLastReadPage(page: lastReadPage, chapter: chapter)
        
        if chapter.endPage == lastReadPage {
            chapterProgressHandler.markChapterAsRead(chapter)
        }
    }
    
    func calculateProgress(page: Int) -> Int {
        let totalPages = chapter.endPage - chapter.startPage + 1
        let pagesRead = page - chapter.startPage + 1
        
        return max(0, min((pagesRead * 100) / totalPages, 100))
    }
    
    func fetchPageInfo(page: Int) async -> PageInfo? {
        print("fetching page \(page) for chapter \(chapter.number)")
        do {
            let url = URL(string: .makeFullURLString(suffix: "/en/page-\(page).html"))
            let imageData = try await networkService.fetchImageData(from: url)

            return .init(chapter: chapter.number, pageNumber: page, secondPageNumber: page.secondPage, imageData: imageData)
        } catch {
            return nil
        }
    }
}


// MARK: - Dependencies
protocol ComicPageNetworkService {
    func fetchImageData(from url: URL?) async throws -> Data
}

protocol ChapterProgressHandler {
    func markChapterAsRead(_ chapter: Chapter)
    func updateLastReadPage(page: Int, chapter: Chapter)
}

protocol ComicImageCache {
    func savePageImage(pageInfo: PageInfo)
    func loadCachedImage(chapter: Int, page: Int) -> PageInfo?
    func updateCurrentPageNumber(_ pageNumber: Int, readProgress: Int)
    func saveChapterCoverImage(imageData: Data, metadata: CoverImageMetaData) throws
}


// MARK: - Extension Dependencies
fileprivate extension Int {
    var isSecondPage: Bool {
        return self == 9 || self == 21
    }
    
    var secondPage: Int? {
        return self == 8 ? 9 : self == 20 ? 21 : nil
    }
}
