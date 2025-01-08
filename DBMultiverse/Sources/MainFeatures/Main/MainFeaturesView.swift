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
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapters: [SwiftDataChapter]
    
    var body: some View {
        ContentView {
            SettingsFeatureNavStack()
        }
        .fetchingChapters(existingChapterNumbers: chapters.map({ $0.number }))
    }
}


// MARK: - ContentView
fileprivate struct ContentView<SettingsTab: View>: View {
    let settingsTab: () -> SettingsTab
    
    init(@ViewBuilder settingsTab: @escaping () -> SettingsTab) {
        self.settingsTab = settingsTab
    }
    
    var body: some View {
        iPhoneMainTabView(loader: MockLoader(), settingsTab: settingsTab)
            .showingConditionalView(when: isPad) {
                Text("iPadView")
            }
    }
}

final class MockLoader: ComicPageLoader {
    func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [ComicPage] {
        return []
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
