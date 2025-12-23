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
    @State private var lastSavedChapterData: CurrentChapterData?
    @Environment(\.scenePhase) private var scenePhase
    
    private let coverImageManager = CoverImageManager()
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: cacheCurrentChapterDataIfNeeded)
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .background  {
                    syncWidgetTimelineIfNeeded()
                }
            }
    }
}


// MARK: - Private Methods
private extension WidgetSyncViewModifier {
    func cacheCurrentChapterDataIfNeeded() {
        if lastSavedChapterData == nil  {
            lastSavedChapterData = coverImageManager.loadCurrentChapterData()
        }
    }
    
    func syncWidgetTimelineIfNeeded() {
        if let currentChapterData = coverImageManager.loadCurrentChapterData(), currentChapterData != lastSavedChapterData  {
            WidgetCenter.shared.reloadTimelines(ofKind: "DBMultiverseWidgets")
            lastSavedChapterData = currentChapterData
        }
    }
}

extension View {
    func syncWidgetData() -> some View {
        modifier(WidgetSyncViewModifier())
    }
}
