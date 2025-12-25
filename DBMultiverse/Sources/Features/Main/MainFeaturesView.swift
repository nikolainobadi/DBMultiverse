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
        mainContent {
            ChapterListFeatureView(eventHandler: SwiftDataChapterListEventHandler.customInit(viewModel: viewModel, chapterList: chapterList))
                .navigationDestination(for: ChapterRoute.self) { route in
                    ComicPageFeatureView(
                        viewModel: .customInit(route: route, store: viewModel, chapterList: chapterList, language: language)
                    )
                }
        } settingsContent: {
            SettingsFeatureNavStack(language: $language, canDismiss: isPad, viewModel: .init())
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


// MARK: - MainContent
private extension MainFeaturesView {
    @ViewBuilder
    func mainContent(comicContent: @escaping () -> some View, settingsContent: @escaping () -> some View) -> some View {
        if isPad {
            iPadMainNavStack(path: $path, comicContent: comicContent, settingsContent: settingsContent)
        } else {
            iPhoneMainTabView(path: $path, comicContent: comicContent, settingsTab: settingsContent)
        }
    }
    
    struct ChapterListFeatureView: View {
        let eventHandler: any ChapterListEventHandler
        
        private var imageSize: CGSize {
            return .init(width: getWidthPercent(15), height: getHeightPercent(isPad ? 15 : 10))
        }
        
        var body: some View {
            ChapterListView(imageSize: imageSize, eventHandler: eventHandler) { selection in
                if isPad {
                    iPadComicPicker(selection: selection)
                } else {
                    iPhoneComicPicker(selection: selection)
                }
            }
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
    static func customInit(route: ChapterRoute, store: MainFeaturesViewModel, chapterList: any ChapterProgressHandler, language: ComicLanguage) -> ComicPageViewModel {
        let currentPageNumber = store.getCurrentPageNumber(for: route.comicType)
        let imageCache = ComicImageCacheManager.customInit(store: store, comicType: route.comicType)
        let manager = ComicPageManager(chapter: route.chapter, language: language, imageCache: imageCache, networkService: ComicPageNetworkServiceAdapter(), chapterProgressHandler: chapterList)

        return .init(chapter: route.chapter, currentPageNumber: currentPageNumber, delegate: manager)
    }
}

private extension ComicImageCacheManager {
    static func customInit(store: any ComicPageStore, comicType: ComicType) -> ComicImageCacheManager {
        return .init(comicType: comicType, store: store, coverImageDelegate: CoverImageDelegateAdapter(), widgetTimelineReloader: WidgetTimelineManager(), comicImageCacheDelegate: FileSystemOperationsAdapter())
    }
}



#if DEBUG
// MARK: - Preview
#Preview {
    MainFeaturesView(language: .constant(.english), viewModel: .init(loader: PreviewDelegate()))
        .withPreviewModifiers()
}

private final class PreviewDelegate: ChapterLoader, WidgetTimelineReloader {
    func notifyProgressChange(progress: Int) { }
    func notifyChapterChange(chapter: Int, progress: Int) { }
    func loadChapters(url: URL?) async throws -> [Chapter] { [] }
}
#endif
