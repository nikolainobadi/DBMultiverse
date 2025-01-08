//
//  MainFeaturesView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import SwiftData
import DBMultiverseComicKit

struct MainFeaturesView: View {
    @AppStorage(.lastReadSpecialPage) private var lastReadSpecialPage: Int = 168
    @AppStorage(.lastReadMainStoryPage) private var lastReadMainStoryPage: Int = 0
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapterList: SwiftDataChapterList
    
    private func getCurrentPage(route: ChapterRoute) -> Int {
        return route.comicType == .story ? lastReadMainStoryPage : lastReadSpecialPage
    }
    
    var body: some View {
        MainNavStack {
            ChapterListFeatureView(eventHandler: .init(chapterList: chapterList))
                .navigationDestination(for: ChapterRoute.self) { route in
                    ComicPageFeatureView(viewModel: .customInit(chapter: route.chapter, currentPage: getCurrentPage(route: route)))
                        .navigationTitle(route.chapter.name)
                }
        } settingsContent: {
            SettingsFeatureNavStack()
        }
        .fetchingChapters(existingChapterNumbers: chapterList.map({ $0.number }))
    }
}


// MARK: - NavStack
fileprivate struct MainNavStack<ComicContent: View, SettingsContent: View>: View {
    @ViewBuilder var comicContent: () -> ComicContent
    @ViewBuilder var settingsContent: () -> SettingsContent
    
    var body: some View {
        iPhoneMainTabView(comicContent: comicContent, settingsTab: settingsContent)
            .showingConditionalView(when: isPad) {
                iPadMainNavStack(comicContent: comicContent, settingsContent: settingsContent)
            }
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesView()
        .withPreviewModifiers()
}


// MARK: - Extension Dependencies
fileprivate extension ComicPageViewModel {
    static func customInit(chapter: Chapter, currentPage: Int) -> ComicPageViewModel {
        return .init(chapter: chapter, currentPageNumber: currentPage, loader: ComicPageLoaderAdapter())
    }
}

final class ComicPageLoaderAdapter: ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] {
        // TODO: - 
        return try await ChapterComicLoaderAdapter().loadPages(chapterNumber: chapterNumber, pages: pages)
    }
}
