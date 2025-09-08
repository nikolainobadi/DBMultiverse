//
//  WidgetSyncViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct WidgetSyncViewModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastSavedChapterData: CurrentChapterData?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) {
                // to prevent widget from being reloaded too often
                if let currentChapterData = CoverImageManager().loadCurrentChapterData(), lastSavedChapterData != currentChapterData {
                    WidgetCenter.shared.reloadAllTimelines()
                    lastSavedChapterData = currentChapterData
                }
            }
    }
}

extension View {
    func syncWidgetData() -> some View {
        modifier(WidgetSyncViewModifier())
    }
}
