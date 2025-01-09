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
    @State private var path: NavigationPath = .init()
    @StateObject var viewModel: MainFeaturesViewModel
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapterList: SwiftDataChapterList
    
    var body: some View {
        MainNavStack(path: $path) {
            ChapterListFeatureView(eventHandler: .customInit(viewModel: viewModel, chapterList: chapterList))
                .navigationDestination(for: ChapterRoute.self) { route in
                    ComicPageFeatureView(viewModel: .customInit(route: route, store: viewModel, chapterList: chapterList))
                }
        } settingsContent: {
            SettingsFeatureNavStack()
        }
        .asyncTask {
            try await viewModel.loadData()
        }
        .syncChaptersWithSwiftData(chapters: viewModel.chapters)
        .withDeepLinkNavigation(path: $path, chapters: chapterList.chapters)
    }
}


// MARK: - NavStack
fileprivate struct MainNavStack<ComicContent: View, SettingsContent: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder var comicContent: () -> ComicContent
    @ViewBuilder var settingsContent: () -> SettingsContent
    
    var body: some View {
        iPhoneMainTabView(path: $path, comicContent: comicContent, settingsTab: settingsContent)
            .showingConditionalView(when: isPad) {
                iPadMainNavStack(path: $path, comicContent: comicContent, settingsContent: settingsContent)
            }
    }
}


// MARK: - Preview
#Preview {
    class PreviewLoader: ChapterLoader {
        func loadChapters() async throws -> [Chapter] { [] }
    }
    
    return MainFeaturesView(viewModel: .init(loader: PreviewLoader()))
        .withPreviewModifiers()
}


// MARK: - Extension Dependencies
fileprivate extension SwiftDataChapterListEventHandler {
    static func customInit(viewModel: MainFeaturesViewModel, chapterList: SwiftDataChapterList) -> SwiftDataChapterListEventHandler {
        return .init(lastReadSpecialPage: viewModel.lastReadSpecialPage, lastReadMainStoryPage: viewModel.lastReadMainStoryPage, chapterList: chapterList)
    }
}

fileprivate extension ComicPageViewModel {
    static func customInit(route: ChapterRoute, store: MainFeaturesViewModel, chapterList: SwiftDataChapterList) -> ComicPageViewModel {
        let currentPageNumber = store.getCurrentPageNumber(for: route.comicType)
        let delegate = ComicPageDelegateAdapter(chapter: route.chapter, comicType: route.comicType, store: store)
        let decorator = ComicPageDelegateDecorator(chapter: route.chapter, decoratee: delegate, chapterList: chapterList)
        
        return .init(chapter: route.chapter, currentPageNumber: currentPageNumber, delegate: decorator)
    }
}
