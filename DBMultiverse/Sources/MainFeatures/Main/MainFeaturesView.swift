//
//  MainFeaturesView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit
import DBMultiverseComicKit

struct MainFeaturesView: View {
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapterList: SwiftDataChapterList
    
    var body: some View {
        ContentView(delegate: .init(chapterList: chapterList)) {
            SettingsFeatureNavStack()
        }
        .fetchingChapters(existingChapterNumbers: chapterList.map({ $0.number }))
    }
}

struct SwiftDataChapterListEventHandler {
    let chapterList: SwiftDataChapterList

    var chapters: [Chapter] {
        return chapterList.chapters
    }
}

extension SwiftDataChapterListEventHandler: ChapterListEventHandler {
    func unreadChapter(_ chapter: DBMultiverseComicKit.Chapter) {
        if chapter.didFinishReading {
            chapterList.unread(chapter)
        } else {
            chapterList.read(chapter)
        }
    }
}


// MARK: - ContentView
fileprivate struct ContentView<SettingsTab: View>: View {
    let delegate: SwiftDataChapterListEventHandler
    let settingsTab: () -> SettingsTab
    
    init(delegate: SwiftDataChapterListEventHandler, @ViewBuilder settingsTab: @escaping () -> SettingsTab) {
        self.delegate = delegate
        self.settingsTab = settingsTab
    }
    
    var body: some View {
        iPhoneMainTabView(loader: MockLoader(), delegate: delegate, settingsTab: settingsTab)
            .showingConditionalView(when: isPad) {
                Text("iPadView")
            }
    }
}

typealias SwiftDataChapterList = [SwiftDataChapter]

extension SwiftDataChapterList {
    var chapters: [Chapter] {
        return map {
            .init(
                name: $0.name,
                number: $0.number,
                startPage: $0.startPage,
                endPage: $0.endPage,
                universe: $0.universe,
                lastReadPage: $0.lastReadPage,
                coverImageURL: $0.coverImageURL,
                didFinishReading: $0.didFinishReading
            )
        }
    }
    
    func read(_ chapter: Chapter) {
        getChapter(chapter)?.didFinishReading = true
    }
    
    func unread(_ chapter: Chapter) {
        getChapter(chapter)?.didFinishReading = false
    }
    
    func updateLastReadPage(page: Int, chapter: Chapter) {
        getChapter(chapter)?.lastReadPage = page
    }
    
    func getChapter(_ chapter: Chapter) -> SwiftDataChapter? {
        return first(where: { $0.name == chapter.name })
    }
}

final class MockLoader: ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [DBMultiverseComicKit.PageInfo] {
        return try await ChapterComicLoaderAdapter().loadPages(chapterNumber: chapterNumber, pages: pages)
            .map({ .init(chapter: $0.chapter, pageNumber: $0.pageNumber, secondPageNumber: $0.secondPageNumber, imageData: $0.imageData)})
            
    }
}


// MARK: - PadView
//fileprivate struct iPadStack: View {
//    @State private var showingPadSettings = false
//    
//    let chapters: [SwiftDataChapter]
//    
//    var body: some View {
//        ComicNavStack {
//            ComicFeatureChildStack(chapters: chapters)
//                .withNavBarButton(buttonContent: .image(.system("gearshape"))) {
//                    showingPadSettings = true
//                }
//                .sheetWithErrorHandling(isPresented: $showingPadSettings) {
//                    SettingsFeatureNavStack()
//                }
//        }
//    }
//}


// MARK: - Preview
#Preview {
    MainFeaturesView()
        .withPreviewModifiers()
}
