//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI
import WidgetKit
import NnSwiftUIKit
import DBMultiverseComicKit

struct DBMultiverseApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastSavedChapterData: CurrentChapterData?

    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .withNnLoadingView()
                .withNnErrorHandling()
                .preferredColorScheme(.dark)
                .initializeSwiftDataModelConatainer()
                .onChange(of: scenePhase) { 
                    // to prevent widget from being reloaded too often
                    if let currentChapterData = CoverImageCache.shared.loadCurrentChapterData(), lastSavedChapterData != currentChapterData {
                        WidgetCenter.shared.reloadAllTimelines()
                        lastSavedChapterData = currentChapterData
                    }
                }
        }
    }
}
