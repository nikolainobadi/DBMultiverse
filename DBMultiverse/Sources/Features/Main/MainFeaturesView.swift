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
    @Binding var language: ComicLanguage
    @State private var path: NavigationPath = .init()
    @StateObject private var viewModel: MainFeaturesViewModel
    @Query(sort: \SwiftDataChapter.number, order: .forward) private var chapterList: SwiftDataChapterList
    
    init(language: Binding<ComicLanguage>, viewModel: @autoclosure @escaping () -> MainFeaturesViewModel) {
        self._language = language
        self._viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        navStack {
            ChapterListFeatureView(eventHandler: .customInit(viewModel: viewModel, chapterList: chapterList))
                .navigationDestination(for: ChapterRoute.self) { route in
                    ComicPageFeatureView(
                        viewModel: .customInit(route: route, store: viewModel, chapterList: chapterList, language: language)
                    )
                }
        } settingsContent: {
            SettingsFeatureNavStack(language: $language, viewModel: .init(), canDismiss: isPad)
        }
        .throwingTask {
            try await viewModel.loadData(language: language)
        }
        .asyncOnChange(item: language, initial: true, hideLoadingIndicator: true) { newLanguage in
            try await viewModel.loadData(language: newLanguage)
        }
        .syncChaptersWithSwiftData(chapters: viewModel.chapters)
        .withDeepLinkNavigation(path: $path, chapters: chapterList.chapters)
        .onChange(of: viewModel.nextChapterToRead) { _, newValue in
            if let newValue {
                // TODO: - only works for main story chapters for now
                path.append(ChapterRoute(chapter: newValue, comicType: .story))
            }
        }
    }
}


// MARK: - NavStack
private extension MainFeaturesView {
    @ViewBuilder
    func navStack(comicContent: @escaping () -> some View, settingsContent: @escaping () -> some View) -> some View {
        iPhoneMainTabView(path: $path, comicContent: comicContent, settingsTab: settingsContent)
            .showingConditionalView(when: isPad) {
                iPadMainNavStack(path: $path, comicContent: comicContent, settingsContent: settingsContent)
            }
    }
}


// MARK: - Extension Dependencies
private extension SwiftDataChapterListEventHandler {
    static func customInit(viewModel: MainFeaturesViewModel, chapterList: SwiftDataChapterList) -> SwiftDataChapterListEventHandler {
        return .init(
            lastReadSpecialPage: viewModel.lastReadSpecialPage,
            lastReadMainStoryPage: viewModel.lastReadMainStoryPage,
            chapterList: chapterList,
            onStartNextChapter: viewModel.startNextChapter(_:)
        )
    }
}

private extension ComicPageViewModel {
    static func customInit(route: ChapterRoute, store: MainFeaturesViewModel, chapterList: SwiftDataChapterList, language: ComicLanguage) -> ComicPageViewModel {
        let currentPageNumber = store.getCurrentPageNumber(for: route.comicType)
        let fileSystemOperations = FileSystemOperationsAdapter()
        let coverImageDelegate = CoverImageDelegateAdapter()
        let imageCache = ComicImageCacheManager(
            comicType: route.comicType,
            store: store,
            fileSystemOperations: fileSystemOperations,
            coverImageDelegate: coverImageDelegate,
            widgetTimelineReloader: store.widgetTimelineReloader
        )
        let networkService = ComicPageNetworkServiceAdapter()
        let manager = ComicPageManager(
            chapter: route.chapter,
            language: language,
            imageCache: imageCache,
            networkService: networkService,
            chapterProgressHandler: chapterList
        )

        return .init(chapter: route.chapter, currentPageNumber: currentPageNumber, delegate: manager)
    }
}



#if DEBUG
// MARK: - Preview
#Preview {
    MainFeaturesView(language: .constant(.english), viewModel: .previewInit(delegate: PreviewDelegate()))
        .withPreviewModifiers()
}

private final class PreviewDelegate: ChapterLoader, WidgetTimelineReloader {
    func notifyProgressChange(progress: Int) { }
    func notifyChapterChange(chapter: Int, progress: Int) { }
    func loadChapters(url: URL?) async throws -> [Chapter] { [] }
}

private extension MainFeaturesViewModel {
    static func previewInit(delegate: PreviewDelegate) -> MainFeaturesViewModel {
        return .init(loader: delegate, widgetTimelineReloader: delegate)
    }
}
#endif
